# frozen_string_literal: true

module Hyrax
  module BatchIngest
    class BatchItemPresenter
      attr_reader :batch_item

      delegate :id, :id_within_batch, :source_location, :error, :repo_object_id,
               :status, to: :batch_item

      def initialize(batch_item)
        @batch_item = batch_item
      end

      def status_span_tag
        "<span class=\"#{status_css_class}\"> #{status_label}</span>".html_safe
      end

      def status_label
        self.class.status_labels[status] || 'unknown'
      end

      def status_css_class
        self.class.status_css_classes[batch_item.status]
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
    end
  end
end
