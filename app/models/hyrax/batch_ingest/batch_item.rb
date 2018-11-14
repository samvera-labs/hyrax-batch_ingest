# frozen_string_literal: true

module Hyrax::BatchIngest
  class BatchItem < ApplicationRecord
    STATUSES = ['initialized', 'enqueued', 'running', 'completed', 'failed'].freeze

    belongs_to :batch

    validates :status, inclusion: { in: STATUSES }
  end
end
