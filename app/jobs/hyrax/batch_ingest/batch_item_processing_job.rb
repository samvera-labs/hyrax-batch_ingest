# frozen_string_literal: true
module Hyrax
  module BatchIngest
    class BatchItemProcessingJob < ApplicationJob
      before_enqueue do
        batch_item = arguments.first
        batch_item.update(status: 'enqueued')
      end

      before_perform do
        batch_item = arguments.first
        batch_item.batch.update(status: 'running') if batch_item.batch.status == 'enqueued'
        batch_item.update(status: 'running')
      end

      after_perform do
        batch_item = arguments.first
        batch_item.update(status: 'completed', repo_object_id: @work.id)
        if batch_item.batch.completed?
          batch = batch_item.batch
          batch.update(status: 'completed')
          if batch.failed_items?
            BatchCompleteMailer.with(batch: batch).batch_completed_with_errors.deliver_later
          else
            BatchCompleteMailer.with(batch: batch).batch_completed_successfully.deliver_later
          end
        end
      end

      rescue_from(StandardError) do |exception|
        batch_item = arguments.first
        # TODO: destroy any objects that were created
        batch_item.update(status: 'failed', error: exception.message)
        batch_item.batch.update(status: 'completed') if batch_item.batch.completed?
      end

      def perform(batch_item)
        @work = config(batch_item).ingester.new(batch_item).ingest
      end

      private

        def config(batch_item)
          @config ||= Hyrax::BatchIngest.config.ingest_types[batch_item.batch.ingest_type.to_sym]
        end
    end
  end
end
