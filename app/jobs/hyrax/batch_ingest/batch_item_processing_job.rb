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
        work_attrs = config.mapper.new(batch_item).map
        work = config.work_class.new
        ability = Ability.new(User.find(email: batch_item.submitter_email))
        env = Hyrax::Actors::Environment.new(work, ability, work_attrs)
        Hyrax::CurationConcern.actor.create(env)
        if work.persisted?
          batch_item.update(status: 'completed', object_id: work.id)
        else
          notify_failed_save(batch_item, work)
        end
      end

      private

        def notify_failed_save(batch_item, work)
          batch_item.update(status: 'failed', error: work.errors.full_messages.join(" "))
        end

        def notify_failed(batch_item, exception)
          batch_item.update(status: 'failed', error: exception.message)
          # TODO: Send email
        end
    end
  end
end
