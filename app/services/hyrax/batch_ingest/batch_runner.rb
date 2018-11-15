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
                             submitter_email: submitter_email,
                             status: 'received')
      end

      def run
        initialize_batch
        read
        enqueue
      end

      def initialize_batch
        batch.save! # batch received
      rescue ActiveRecord::ActiveRecordError => e
        notify_failed(e)
        false
      end

      def read
        raise ArgumentError, "Batch not initialized yet" unless batch.persisted?
        reader = config.reader.new(batch.source_location)
        reader.read
        fail_on_mismatch(batch, reader)
        populate_batch_from_reader(batch, reader)
        batch.save! # batch accepted
      rescue ReaderError, ActiveRecord::ActiveRecordError => e
        notify_failed(e)
      end

      def enqueue
        raise ArgumentError, "Batch not read yet" unless batch.status == 'accepted'
        # notify_failed("No batch items found.") if batch.batch_items.blank?
        batch.batch_items.each do |item|
          BatchItemProcessingJob.perform_later(item)
          item.update(status: 'enqueued') # batch item enqueued
        end
        batch.update(status: 'enqueued') # batch enqueued
        # TODO: Send email that batch has been enqueued
      rescue ActiveRecord::ActiveRecordError => e
        notify_failed(e)
      end

      private

        # Compare values from batch object with values read in from the reader.
        # Raise errors on any mismatches that are supposed to match.
        def fail_on_mismatch(batch, reader)
          raise ReaderError, "Conflict: Different submitter emails found (#{batch.submitter_email} and #{reader.submitter_email})" if batch.submitter_email != reader.submitter_email
        end

        def populate_batch_from_reader(batch, reader)
          batch.batch_items = reader.batch_items # batch item initialized (and now persisted)
          batch.submitter_email = reader.submitter_email if reader.submitter_email
          if reader.error
            batch.error = reader.error
            batch.status = 'failed'
          else
            batch.status = 'accepted'
          end
        end

        # def ensure_submitter_email(reader)
        #   if reader.submitter_email.present?
        #     if batch.submitter_email.present? && batch.submitter_email != reader.submitter_email
        #       raise ReaderError, "Conflict: Different submitter emails found (#{batch.submitter_email} and #{reader.submitter_email})"
        #     else
        #       batch.submitter_email = reader.submitter_email
        #     end
        #   end
        # end

        def config
          @config ||= Hyrax::BatchIngest.config.ingest_types[batch.ingest_type.to_sym]
        end

        def notify_failed(exception)
          batch.update(status: 'failed', error: exception.message)
          # TODO: Send email
        end
    end
  end
end
