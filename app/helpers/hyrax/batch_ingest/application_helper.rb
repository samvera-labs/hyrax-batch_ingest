# frozen_string_literal: true
module Hyrax
  module BatchIngest
    module ApplicationHelper
      def sort_order
        params[:order] || @default_item_sort
      end

      def sort_link_to(body, field)
        sort_field, sort_direction = sort_order.split
        if sort_field == field && sort_direction == 'asc'
          link_to(body, { order: "#{field} desc" }, class: 'batch_sort_asc')
        elsif sort_field == field
          link_to(body, { order: "#{field} asc" }, class: 'batch_sort_desc')
        else
          link_to(body, { order: "#{field} asc" }, class: 'batch_sort_none')
        end
      end
    end
  end
end
