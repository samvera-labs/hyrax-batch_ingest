# frozen_string_literal: true

module Hyrax::BatchIngest
  class Batch < ApplicationRecord
    STATUSES = ['received', 'accepted', 'enqueued', 'running', 'completed', 'failed'].freeze

    has_many :batch_items

    validates :status, inclusion: { in: STATUSES }

    def completed?
      batch_items.all? { |item| item.status == 'completed' || item.status == 'failed' }
    end

    def admin_set
      return unless admin_set_id
      @admin_set ||= AdminSet.find(admin_set_id)
    end

    def collection
      # TODO: return instance of Collection object
    end
  end
end
