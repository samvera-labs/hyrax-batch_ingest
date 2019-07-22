# frozen_string_literal: true
module Hyrax
  module BatchIngest
    class BatchRunner
      attr_reader :batch

      def initialize(batch: nil, ingest_type: nil, source_location: nil, submitter_email: nil, admin_set_id: nil)
        @batch = batch
        @batch ||= Batch.new(ingest_type: ingest_type,
                             source_location: source_location,
                             admin_set_id: admin_set_id,
                             submitter_email: submitter_email)
      end

      def run
        if initialize_batch
          # rubocop:disable Style/IfUnlessModifier
          if read
            enqueue
          end
        end
      end

      def initialize_batch
        batch.status = 'received'
        batch.start_time = DateTime.now.in_time_zone
        batch.save! # batch received
      rescue ActiveRecord::ActiveRecordError => e
        notify_failed(e)
        false
      end

      def read
        raise ArgumentError, "Batch not initialized yet" unless batch.persisted?
        reader = config.reader.new(batch.source_location, config.reader_options)
        fail_on_mismatch(batch, reader)
        populate_batch_from_reader(batch, reader)
        batch.save! # batch accepted
        # once batch is persisted we don't need its manifest anymore, delete the file to prevent redundant process
        reader.delete_manifest
      rescue ReaderError, ActiveRecord::ActiveRecordError => e
        notify_failed(e)
        false
      end

      def enqueue
        raise ArgumentError, "Batch not read yet" unless batch.status == 'accepted'
        batch.update(status: 'enqueued')
        batch.batch_items.each do |batch_item|
          BatchItemProcessingJob.perform_later(batch_item: batch_item)
        end
        BatchBeginMailer.with(batch: batch).batch_started_successfully.deliver_later
      rescue ActiveRecord::ActiveRecordError => e
        notify_failed(e)
        false
      end

      private

        # Compare values from batch object with values read in from the reader.
        # Raise errors on any mismatches that are supposed to match.
        def fail_on_mismatch(batch, reader)
          [:submitter_email, :admin_set_id].each do |field_name|
            if batch.send(field_name) && reader.send(field_name) && (batch.send(field_name) != reader.send(field_name))
              raise ReaderError, "Conflict: Different values for #{field_name.to_s.tr('_', ' ')} found (#{batch.send(field_name)} and #{reader.send(field_name)})"
            end
          end
        end

        def populate_batch_from_reader(batch, reader)
          batch.batch_items = reader.batch_items # batch item initialized (and now persisted)
          batch.submitter_email = reader.submitter_email if reader.submitter_email.present?
          batch.admin_set_id = reader.admin_set_id if reader.admin_set_id.present?
          batch.status = 'accepted'
        end

        def config
          @config ||= Hyrax::BatchIngest.config.ingest_types[batch.ingest_type.to_sym]
        end

        def notify_failed(exception)
          batch.update(status: 'failed', error: exception.message)
          BatchBeginMailer.with(batch: batch).batch_started_with_errors.deliver_later
        end
    end
  end
end
