# frozen_string_literal: true
module Hyrax
  module BatchIngest
    class BatchItemProcessingJob < ApplicationJob
      def perform(batch_item)
        batch_item.batch.update(status: 'running') if batch_item.batch.status == 'enqueued'
        batch_item.update(status: 'running')
        config = Hyrax::BatchIngest::Config.new(batch_item.batch.ingest_type)
        validation_result = config.source_validator.validate(batch_item)
        if validation_result.failure?
          notify_invalid(batch_item, validation_result)
          return
        end
        # TODO: read batch_item.source_data or batch_item.source_location and feed into mapper?
        work = config.mapper.map(batch_item)
        if work.save
          batch_item.update(status: 'completed', object_id: work.id)
        else
          notify_failed_save(batch_item, work)
        end
      rescue StandardError => e
        notify_failed(batch_item, e)
      ensure
        batch_item.batch.update('completed') if batch_item.batch.completed?
      end

      private

        def notify_failed_save(batch_item, work)
          batch_item.update(status: 'failed', error: work.errors.full_messages.join(" "))
        end

        def notify_invalid(batch_item, validation_result)
          batch_item.update(status: 'failed', error: validation_result.messages(full: true).values.flatten.join(" "))
        end

        def notify_failed(batch_item, exception)
          batch_item.update(status: 'failed', error: exception.message)
          # TODO: Send email
        end
    end
  end
end
