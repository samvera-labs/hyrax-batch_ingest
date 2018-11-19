# frozen_string_literal: true
module Hyrax::BatchIngest
  class BatchBeginMailer < ApplicationMailer
    def batch_started_successfully
      @batch = params[:batch]
      mail(to: @batch.submitter_email, subject: 'Hyrax Batch Ingest Started (Success)')
    end

    def batch_started_with_errors
      @batch = params[:batch]
      mail(to: @batch.submitter_email, subject: 'Hyrax Batch Ingest Started (With Errors)')
    end

    private

      def receiver
        # TODO: get default receiver from config
        params[:submitter_email].present? ? params[:submitter_email] : 'admin@example.com'
      end
  end
end
