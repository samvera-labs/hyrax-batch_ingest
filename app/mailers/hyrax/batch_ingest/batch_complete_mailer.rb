# frozen_string_literal: true
module Hyrax::BatchIngest
  class BatchCompleteMailer < ApplicationMailer
    def batch_completed_successfully
      @batch = params[:batch]
      mail(to: receiver, subject: 'Hyrax Batch Ingest Completed (Success)')
    end

    def batch_completed_with_errors
      @batch = params[:batch]
      mail(to: receiver, subject: 'Hyrax Batch Ingest Completed (With Errors)')
    end

    private

      def receiver
        # TODO: get default receiver from config
        @batch.submitter_email.present? ? @batch.submitter_email : 'admin@example.com'
      end
  end
end
