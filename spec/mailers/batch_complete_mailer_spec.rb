# frozen_string_literal: true
require "rails_helper"

RSpec.describe Hyrax::BatchIngest::BatchCompleteMailer, type: :mailer do
  before do
    Rails.application.config.action_mailer.default_url_options = { host: 'http://example.com' }
    Rails.application.config.action_mailer.default_options = { from: 'admin@example.com', to: 'admin@example.com' }
  end
  let(:batch) { create(:batch) }

  describe "batch_completed_successfully" do
    let(:mail) { Hyrax::BatchIngest::BatchCompleteMailer.with(batch: batch).batch_completed_successfully }

    it "renders the headers" do
      expect(mail.subject).to eq('Hyrax Batch Ingest Completed (Success)')
      expect(mail.to).to eq([batch.submitter_email])
      expect(mail.from).to eq([Rails.application.config.action_mailer.default_options[:from]])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include('Batch Ingest Completed Successfully')
      expect(mail.body.encoded).to include("#{Rails.application.config.action_mailer.default_url_options[:host]}/batches/#{batch.id}")
    end
  end

  describe "batch_completed_with_errors" do
    let(:mail) { Hyrax::BatchIngest::BatchCompleteMailer.with(batch: batch).batch_completed_with_errors }

    before do
      batch.error = 'Test Error.'
      batch.batch_items << [create(:batch_item, batch: batch, error: 'Test Item Error')]
    end

    it "renders the headers" do
      expect(mail.subject).to eq('Hyrax Batch Ingest Completed (With Errors)')
      expect(mail.to).to eq([batch.submitter_email])
      expect(mail.from).to eq([Rails.application.config.action_mailer.default_options[:from]])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include('Batch Ingest Completed But Had Errors')
      expect(mail.body.encoded).to include("#{Rails.application.config.action_mailer.default_url_options[:host]}/batches/#{batch.id}")
    end

    it "renders the error info" do
      expect(mail.body.encoded).to include(batch.error)
      expect(mail.body.encoded).to include('Total: 1')
      expect(mail.body.encoded).to include('Errors: 1')
    end
  end
end
