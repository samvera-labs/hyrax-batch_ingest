# frozen_string_literal: true

module Hyrax::BatchIngest
  class Batch < ApplicationRecord
    has_many :batch_items

    def completed?
      batch_items.all? { |item| item.status == :success || item.status == :failed }
    end

    def admin_set
      @admin_set ||= AdminSet.find(admin_set_id) if admin_set_id
    end

    def collection
      # TODO: return instance of Collection object
    end
  end
end
