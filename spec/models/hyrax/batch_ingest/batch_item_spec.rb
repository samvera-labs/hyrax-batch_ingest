# frozen_string_literal: true
require 'rails_helper'
require 'rspec/collection_matchers'

RSpec.describe Hyrax::BatchIngest::BatchItem do
  describe 'validate' do
    before { batch_item.validate }
    context 'with an invalid status' do
      let(:batch_item) { build(:batch_item, status: "not a valid status") }
      it 'adds an error for invalid status' do
        expect(batch_item).to have(1).error_on(:status)
      end
    end
  end

  describe 'methods delegated to Batch' do
    let(:batch) { build(:batch, submitter_email: "submitter@example.org") }
    let(:batch_item) { build(:batch_item, batch: batch) }
    # set up spies on the batch
    before do
      allow(batch).to receive(:submitter_email)
      allow(batch).to receive(:submitter)
    end

    it 'delegates #submitter_email to #batch instance' do
      batch_item.submitter_email
      expect(batch).to have_received(:submitter_email)
    end

    it 'delegates #submitter to #batch instance' do
      batch_item.submitter
      expect(batch).to have_received(:submitter)
    end
  end
end
