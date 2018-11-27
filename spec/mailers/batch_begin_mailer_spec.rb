# frozen_string_literal: true
require "rails_helper"

RSpec.describe Hyrax::BatchIngest::BatchBeginMailer, type: :mailer do
  before do
    Rails.application.config.action_mailer.default_url_options = { host: 'http://example.com' }
    Rails.application.config.action_mailer.default_options = { from: 'admin@example.com', to: 'admin@example.com' }
  end
  let(:batch) { create(:batch) }

  describe "batch_started_successfully" do
    let(:mail) { Hyrax::BatchIngest::BatchBeginMailer.with(batch: batch).batch_started_successfully }

    it "renders the headers" do
      expect(mail.subject).to eq('Hyrax Batch Ingest Started (Success)')
      expect(mail.to).to eq([batch.submitter_email])
      expect(mail.from).to eq([Rails.application.config.action_mailer.default_options[:from]])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include('Batch Ingest Started Successfully')
      expect(mail.body.encoded).to include("#{Rails.application.config.action_mailer.default_url_options[:host]}/batches/#{batch.id}")
    end
  end

  describe "batch_started_with_errors" do
    let(:mail) { Hyrax::BatchIngest::BatchBeginMailer.with(batch: batch).batch_started_with_errors }

    before do
      allow(batch.errors).to receive(:full_messages).and_return(['Error 1', 'Error 2'])
    end

    it "renders the headers" do
      expect(mail.subject).to eq('Hyrax Batch Ingest Started (With Errors)')
      expect(mail.to).to eq([batch.submitter_email])
      expect(mail.from).to eq([Rails.application.config.action_mailer.default_options[:from]])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include('Batch Ingest Started But Had Errors')
      expect(mail.body.encoded).to include("#{Rails.application.config.action_mailer.default_url_options[:host]}/batches/#{batch.id}")
      batch.errors.full_messages.each do |message|
        expect(mail.body.encoded).to include(message)
      end
    end
  end
end
