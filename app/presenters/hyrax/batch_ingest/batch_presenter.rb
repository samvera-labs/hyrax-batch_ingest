# frozen_string_literal: true

module Hyrax
  module BatchIngest
    class BatchPresenter
      DATETIME_FORMAT = "%m/%d/%y %l:%M %p"
      DURATION_FORMAT = '%H:%M:%S'

      attr_reader :batch, :request

      delegate :id, :submitter_email, :source_location, :batch_items, :error,
               :count_by_status, :count_by_object, :uploaded_filename,
               to: :batch

      def initialize(batch, request = nil)
        @batch = batch
        @request = request
      end

      def collection_title
        batch.collection&.title&.first
      end

      def ingest_type
        Hyrax::BatchIngest.config.ingest_types[batch.ingest_type.to_sym].label
      end

      def status_span_tag
        # TODO: Style this span
        "<span class=\"#{status_css_class}\"> #{status_label.capitalize}</span>".html_safe
      end

      def created_at
        batch.created_at.strftime(DATETIME_FORMAT)
      end

      def updated_at
        batch.updated_at.strftime(DATETIME_FORMAT)
      end

      def status_label
        self.class.status_labels[batch.status] || 'unknown'
      end

      def status_css_class
        self.class.status_css_classes[batch.status]
      end

      def admin_set_title
        batch.admin_set&.title&.first
      end

      def error_html
        error.gsub("\n", "<br>")
      end

      def batch_item_presenters
        @batch_item_presenters ||= batch_items.map do |batch_item|
          Hyrax::BatchIngest::BatchItemPresenter.new(batch_item)
        end
      end

      def batch_item_count
        @batch_item_count ||= batch.batch_items.count
      end

      def start_time
        # the gsub is to reduce multiple consecutive spaces down to 1 space.
        batch&.start_time&.strftime(DATETIME_FORMAT)&.gsub(/ +/, ' ')
      end

      def end_time
        # the gsub is to reduce multiple consecutive spaces down to 1 space.
        batch&.end_time&.strftime(DATETIME_FORMAT)&.gsub(/ +/, ' ')
      end

      def run_time
        return unless batch.start_time
        # Get the time diff im seconds, then use Time.at and str
        run_time = (batch.end_time || DateTime.now.in_time_zone).to_i - batch.start_time.to_i
        Time.at(run_time).utc.strftime(DURATION_FORMAT)
      end

      def batch_actions
        [
          { text: "List View", url: "/batches/#{id}" },
          { text: "Summary View", url: "/batches/#{id}/summary" }
        ].each do |action|
          action[:active] = true if request&.path == action[:url]
        end
      end

      class << self
        def status_labels
          {
            received: I18n.t('hyrax.batch_ingest.batches.status.received'),
            accepted: I18n.t('hyrax.batch_ingest.batches.status.accepted'),
            enqueued: I18n.t('hyrax.batch_ingest.batches.status.enqueued'),
            running: I18n.t('hyrax.batch_ingest.batches.status.running'),
            completed: I18n.t('hyrax.batch_ingest.batches.status.completed'),
            failed: I18n.t('hyrax.batch_ingest.batches.status.failed')
          }.with_indifferent_access
        end

        def status_css_classes
          {
            'received' => 'fa fa-info',
            'accepted' => 'fa fa-info',
            'enqueued' => 'fa fa-info',
            'running' => 'fa fa-refresh fa-sync',
            'completed' => 'fa fa-check-circle',
            'failed' => 'fa fa-exclamation-triangle'
          }
        end
      end
    end
  end
end
