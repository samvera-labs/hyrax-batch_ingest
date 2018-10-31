module Hyrax
  module BatchIngest
    class BatchRunner
      attr_reader :batch, :ingest_type, :file_location, :submitter, :admin_set_id

      def initialize(:ingest_type, :source_location, submitter_email: nil, admin_set_id: nil)
        @ingest_type = ingest_type
        @source_location = source_location
        @submitter_email = submitter_email
        @admin_set_id = admin_set_id
      end

      def run
        setup_batch
        config.reader.read(@batch)
        @batch.status = :accepted
        @batch.save
        @batch.batch_items.each do |item|
          BatchItemProcessingJob.perform_later(item, config.source_validator, config.mapper)
        end
      rescue ReaderError => e
        notify_corrupt_batch(e)
      end

      private

        def setup_batch
          @batch.ingest_type = @ingest_type
          @batch.source_location = @source_location
          @batch.admin_set_id = @admin_set_id
          @batch.submitter_email = @submitter_email
          @batch.status = :received
          @batch.save
        end

        def config
          @config ||= Hyrax::BatchIngest::Config.new(ingest_type: @ingest_type)
        end

        def notify_corrupt_batch(exception)
          @batch.update(status: :failed, error: e.message)
        end
    end
  end
end
