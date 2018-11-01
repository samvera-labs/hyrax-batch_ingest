module Hyrax
  module BatchIngest
    class BatchItemProcessingJob < ApplicationJob
      def perform(batch_item)
        batch_item.update(status: :running)
        config = Hyrax::BatchIngest::Config.new(batch_item.batch.ingest_type)
        validation_result = config.source_validator.validate(batch_item)
        if validation_result.failure?
          notify_invalid(batch_item, validation_result)
          return
        end
        # TODO: read batch_item.source_data or batch_item.source_location and feed into mapper?
        work = config.mapper.map(batch_item)
        if work.save
          batch_item.update(status: :success)
        else
          notify_failed_save(batch_item, work)
        end
        batch_item.batch.update(:complete) if batch_item.batch.completed?
      end

      private

        def notify_failed_save(batch_item, work)
          batch_item.update(status: :failed, error: work.errors.full_messages.join(" "))
        end

        def notify_invalid(batch_item, validation_result)
          batch_item.update(status: :failed, error: validation_result.messages(full: true).values.flatten.join(" "))
        end
    end
  end
end
