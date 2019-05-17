# frozen_string_literal: true
module Hyrax
  module BatchIngest
    class BatchItemProcessingJob < ApplicationJob
      before_enqueue do
        batch_item = named_arguments[:batch_item]
        batch_item.update(status: 'enqueued')
      end

      before_perform do
        batch_item = named_arguments[:batch_item]
        batch_item.batch.update(status: 'running') if batch_item.batch.status == 'enqueued'
        batch_item.update(status: 'running')
      end

      after_perform do
        batch_item = named_arguments[:batch_item]
        batch_item.update(status: 'completed', repo_object_id: @work.id, repo_object_class_name: @work.class)
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
        batch_item = named_arguments[:batch_item]
        # TODO: destroy any objects that were created
        raise exception unless batch_item

        error_msg = exception.message
        error_msg += "\n\n#{exception.backtrace.join("\n")}" if Rails.env == "development"
        batch_item.update(status: 'failed', error: error_msg)
        batch_item.batch.update(status: 'completed') if batch_item.batch.completed?
      end

      def perform(batch_item:)
        ingester_class = config(batch_item).ingester
        ingester_options = config(batch_item).ingester_options
        @work = ingester_class.new(batch_item, ingester_options).ingest
      end

      private

        # named_arguments
        # Helper method for retrieving a hash of named arguments from
        # #arguments. This comes in handy when you have named arguments in your
        # #perform method, and need to access them by name in your before/after
        # hooks (e.g. before_perform) whose blocks are only passed a single
        # argument representing the job, but not the original arguments to
        # the #perform method.
        # @return Hash the hash of named arguments passed to #perform.
        def named_arguments
          arguments.select { |arg| arg.is_a? Hash }.first || {}
        end

        def config(batch_item)
          Hyrax::BatchIngest.config.ingest_types[batch_item.batch.ingest_type.to_sym]
        end
    end
  end
end
