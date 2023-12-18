# frozen_string_literal: true

module Hyrax::BatchIngest
  class Batch < ApplicationRecord
    STATUSES = ['received', 'accepted', 'enqueued', 'running', 'completed', 'failed'].freeze

    has_many :batch_items

    validates :status, inclusion: { in: STATUSES }

    paginates_per 20

    def completed?
      batch_items.all? { |item| item.status == 'completed' || item.status == 'failed' }
    end

    def admin_set
      return unless admin_set_id
      @admin_set ||= Hyrax.query_service.find_by(id: admin_set_id)
    end

    def collection
      # TODO: return instance of Collection object
    end

    def failed_items?
      batch_items.any?(&:error)
    end

    def submitter
      return nil if submitter_email.nil?
      @submitter ||= User.find_by! email: submitter_email
    end

    def count_by_status
      batch_items.group(:status).count
    end

    def count_by_object
      batch_items
        .where.not(repo_object_class_name: nil)
        .group(:repo_object_class_name)
        .count
    end
  end
end
