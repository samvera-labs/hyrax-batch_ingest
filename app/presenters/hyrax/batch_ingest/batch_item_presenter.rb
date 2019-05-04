# frozen_string_literal: true

module Hyrax
  module BatchIngest
    class BatchItemPresenter
      attr_reader :batch_item

      delegate :id, :id_within_batch, :source_location, :error, :repo_object_id,
               :status, :repo_object_class_name, to: :batch_item

      def initialize(batch_item)
        @batch_item = batch_item
      end

      def status_span_tag(index)
        "<span data-toggle=\"collapse\" data-target=\"#error_#{index}\" class=\"#{status_css_class}\" style=\"cursor: pointer;\">#{status_label}</span>".html_safe
      end

      def status_label
        self.class.status_labels[status]
      end

      def status_css_class
        "clickable #{self.class.status_css_classes[batch_item.status]}"
      end

      # @return [String] the relative URL to the #show page for the repository
      #  object corresponding to the :repo_object_id value of the batch item.
      def repo_object_path
        return nil unless repo_object_path_helper && repo_object_id
        send(repo_object_path_helper, repo_object_id)
      end

      # @return [String] the human-readable name of the model if we can get it;
      #  otherwise returns the :repo_object_class_name for the batch item as-is.
      def repo_object_display_name
        repo_object_class&.model_name&.human || repo_object_class_name
      end

      class << self
        def status_labels
          {
            initialized: I18n.t('hyrax.batch_ingest.batch_items.status.initialized'),
            enqueued:    I18n.t('hyrax.batch_ingest.batch_items.status.enqueued'),
            running:     I18n.t('hyrax.batch_ingest.batch_items.status.running'),
            completed:   I18n.t('hyrax.batch_ingest.batch_items.status.completed'),
            failed:      I18n.t('hyrax.batch_ingest.batch_items.status.failed')
          }.with_indifferent_access
        end

        def status_css_classes
          {
            initialized:  'fa fa-info',
            enqueued:     'fa fa-info',
            running:      'fa fa-refresh fa-sync',
            completed:    'fa fa-check-circle',
            failed:       'fa fa-exclamation-triangle'
          }.with_indifferent_access
        end
      end

      private

        def repo_object_class
          Object.const_get(batch_item.repo_object_class_name.to_s)
        rescue NameError
          nil
        end

        def repo_object_path_helper
          return nil unless repo_object_class
          self.class.include Rails.application.routes.url_helpers
          "hyrax_#{repo_object_class.model_name.singular}_path"
        end
    end
  end
end
