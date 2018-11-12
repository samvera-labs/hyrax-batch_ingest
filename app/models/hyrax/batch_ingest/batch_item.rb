# frozen_string_literal: true

module Hyrax::BatchIngest
  class BatchItem < ApplicationRecord
    STATUSES = ['initialized', 'enqueued', 'running', 'succeeded', 'failed'].freeze

    belongs_to :batch
    validates :status, inclusion: { in: STATUSES }
    paginates_per 20
  end
end
