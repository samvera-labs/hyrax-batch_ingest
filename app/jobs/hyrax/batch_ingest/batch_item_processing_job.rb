# frozen_string_literal: true
module Hyrax
  module BatchIngest
    class BatchItemProcessingJob < ApplicationJob
      before_perform do
        batch_item = arguments.first
        batch_item.batch.update(status: 'running') if batch_item.batch.status == 'enqueued'
        batch_item.update(status: 'running')
      end

      after_perform do
        batch_item = arguments.first
        batch_item.batch.update(status: 'completed') if batch_item.batch.completed?
      end

      rescue_from(StandardError) do |exception|
        batch_item = arguments.first
        notify_failed(batch_item, exception)
        batch_item.batch.update(status: 'completed') if batch_item.batch.completed?
      end

      def perform(batch_item)
        config = Hyrax::BatchIngest.config.ingest_types[batch_item.batch.ingest_type.to_sym]
        # validation_result = config.source_validator.new(batch_item).validate
        # if validation_result.failure?
        #   notify_invalid(batch_item, validation_result)
        #   return
        # end
        work = config.mapper.new(batch_item).map
        if work.save
          batch_item.update(status: 'completed', object_id: work.id)
        else
          notify_failed_save(batch_item, work)
        end
      end

      private

        def notify_failed_save(batch_item, work)
          batch_item.update(status: 'failed', error: work.errors.full_messages.join(" "))
        end

        # def notify_invalid(batch_item, validation_result)
        #   batch_item.update(status: 'failed', error: validation_result.messages(full: true).values.flatten.join(" "))
        # end

        def notify_failed(batch_item, exception)
          batch_item.update(status: 'failed', error: exception.message)
          # TODO: Send email
        end
    end
  end
end
