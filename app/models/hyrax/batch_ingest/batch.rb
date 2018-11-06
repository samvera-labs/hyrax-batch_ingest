# frozen_string_literal: true

module Hyrax::BatchIngest
  class Batch < ApplicationRecord
    has_many :batch_items

    def completed?
      batch_items.all? { |item| item.status == :success || item.status == :failed }
    end
  end
end
