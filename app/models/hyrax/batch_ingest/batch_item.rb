# frozen_string_literal: true

module Hyrax::BatchIngest
  class BatchItem < ApplicationRecord
    STATUSES = ['initialized', 'enqueued', 'running', 'completed', 'failed'].freeze

    belongs_to :batch
    validates :status, inclusion: { in: STATUSES }
    paginates_per 20

    delegate :submitter_email, :submitter, to: :batch

    def repo_object_exists?
      return false unless repo_object_id
      !::SolrDocument.find(repo_object_id).nil?
    rescue Blacklight::Exceptions::RecordNotFound
      false
    end
  end
end
