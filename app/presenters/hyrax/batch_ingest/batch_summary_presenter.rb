# frozen_string_literal: true

module Hyrax
  module BatchIngest
    class BatchSummaryPresenter < BatchPresenter
      def finished_summary
        @finished_summary ||= begin
          total = count_by_status.values_at('completed', 'failed', 'expunged').map(&:to_i).sum
          {
            total: total,
            rows: [
              {
                count: count_by_status['completed'],
                percent: percentage(count_by_status['completed'].to_i, total, 1),
                status: 'Success'
              },
              {
                count: count_by_status['failed'],
                percent: percentage(count_by_status['failed'].to_i, total, 1),
                status: 'Failed'
              },
              {
                count: count_by_status['expunged'],
                percent: percentage(count_by_status['expunged'].to_i, total, 1),
                status: 'Expunged'
              }
            ]
          }
        end
      end

      def remaining_summary
        @remaining_summary ||= begin
          statuses_for_remaining = ['initialized', 'enqueued', 'running']
          total = count_by_status.values_at(*statuses_for_remaining).map(&:to_i).sum
          {
            total: total,
            rows: count_by_status.slice(*statuses_for_remaining).map do |status, count|
              {
                count: count,
                percent: percentage(count.to_i, total, 1),
                status: batch_item_status_label_for(status)
              }
            end
          }
        end
      end

      def object_summary
        @object_summary ||= {
          total: batch_items_ingested.count,
          # Use BatchItem's count_by_object hash, and convert class names to
          # their human readable counterparts if possible.
          rows: count_by_object.map do |class_name, count|
            {
              count: count,
              percent: percentage(count.to_i, batch_items_ingested.count, 1),
              object_type: friendly_object_name(class_name)
            }
          end
        }
      end

      def error_summary
        @error_summary ||= {
          total: batch_items_with_errors.count,
          rows: error_summary_rows
        }
      end

      private

        def error_summary_rows
          @error_summary_rows ||= begin
            rows = {}
            batch_items_with_errors.each do |batch_item|
              error = batch_item.error.split("\n").first
              if rows.key?(error)
                rows[error][:count] += 1
                rows[error][:ids_within_batch] << batch_item.id_within_batch
              else
                rows[error] = {
                  count: 1,
                  ids_within_batch: [batch_item.id_within_batch],
                  error: error
                }
              end
            end
            # calculate percentages
            rows.each_value { |row| row[:percent] = (100.0 * row[:count] / batch_items_with_errors.count).round(1) }
            # return an array rows
            rows.values
          end
        end

        def batch_items_with_errors
          @batch_items_with_errors ||= batch_items.select(&:error)
        end

        def batch_items_ingested
          @batch_items_ingested ||= batch_items.select(&:repo_object_id)
        end

        def batch_item_status_label_for(status)
          BatchItemPresenter.status_labels[status]
        end

        def percentage(numerator, denominator, decimal_places = 0)
          (100.0 * numerator / denominator).round(decimal_places.to_i)
        end

        def friendly_object_name(class_name)
          Object.const_get(class_name).model_name.human
        rescue
          class_name
        end
    end
  end
end
