# frozen_string_literal: true

module Hyrax::BatchIngest
  class BatchItem < ApplicationRecord
    STATUSES = ['initialized', 'enqueued', 'running', 'completed', 'failed', 'expunged'].freeze

    belongs_to :batch
    validates :status, inclusion: { in: STATUSES }
    paginates_per 20

    delegate :submitter_email, :submitter, to: :batch
  end
end
