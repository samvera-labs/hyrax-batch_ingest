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
        # TODO: destroy any objects that were created
        notify_failed(batch_item, exception)
        batch_item.batch.update(status: 'completed') if batch_item.batch.completed?
      end

      def perform(batch_item)
        work = config(batch_item).ingester.new(batch_item).ingest
        batch_item.update(status: 'completed', object_id: work.id)
      end

      private

        def config(batch_item)
          @config ||= Hyrax::BatchIngest.config.ingest_types[batch_item.batch.ingest_type.to_sym]
        end

        def notify_failed(batch_item, exception)
          batch_item.update(status: 'failed', error: exception.message)
          # TODO: Send email
        end
    end
  end
end
