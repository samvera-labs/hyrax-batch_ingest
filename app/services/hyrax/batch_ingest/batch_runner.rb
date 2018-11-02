# frozen_string_literal: true
module Hyrax
  module BatchIngest
    class BatchRunner
      attr_reader :batch

      def initialize(ingest_type:, source_location:, submitter_email: nil, admin_set_id: nil)
        @batch = Batch.new(ingest_type: ingest_type,
                           source_location: source_location,
                           admin_set_id: admin_set_id,
                           submitter_email: submitter_email,
                           status: :received)
      end

      def run
        batch.save! # batch received
        read_batch
        enqueue_batch
      rescue ReaderError => e
        notify_failed(e)
      rescue ActiveRecord::ActiveRecordError => e
        notify_failed(e)
      end

      private

        def read_batch
          reader = config.reader.new(batch.source_location)
          batch.batch_items = reader.batch_items # batch item initialized (and now persisted)
          notify_conflict(batch, reader) if batch.submitter_email.present? && reader.submitter_email.present? && batch.submitter_email != reader.submitter_email
          batch.submitter_email = reader.submitter_email if reader.submitter_email.present?
          batch.status = :accepted
          batch.save! # batch accepted
        end

        def enqueue_batch
          batch.batch_items.each do |item|
            BatchItemProcessingJob.perform_later(item, config.source_validator, config.mapper)
            batch_item.update(status: :enqueued) # batch item enqueued
          end
          batch.update(status: :enqueued) # batch enqueued
          # TODO: Send email that batch has been enqueued
        end

        def config
          @config ||= Hyrax::BatchIngest::Config.new(ingest_type: batch.ingest_type)
        end

        def notify_failed(exception)
          batch.update(status: :failed, error: exception.message)
          # TODO: Send email
        end
    end
  end
end
