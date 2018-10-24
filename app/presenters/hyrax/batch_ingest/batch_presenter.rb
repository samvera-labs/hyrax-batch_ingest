# frozen_string_literal: true

module Hyrax
  module BatchIngest
    class BatchPresenter
      attr_reader :batch
      def initialize(batch)
        @batch = batch
      end

      delegate :id, :submitter_email, :source_location, :batch_items, :error,
               :created_at, :updated_at, to: :batch

      def collection_title
        batch.collection&.title&.first
      end

      def status
        status_labels[batch.status]
      end

      def admin_set_title
        batch.admin_set&.title&.first
      end

      private

        def status_labels
          # TODO: use i18n
          {
            started: "Batch Started",
            processing: "Batch Processing",
            complete: "Batch Complete"
          }
        end
    end
  end
end
