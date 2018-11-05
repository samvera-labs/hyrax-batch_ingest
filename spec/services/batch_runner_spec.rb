# frozen_string_literal: true
require 'rails_helper'

Rspec.describe Hyrax::BatchIngest::BatchRunner do
  let(:batch_runner) do
    described_class.new(ingest_type: ingest_type,
                        source_location: source_location,
                        admin_set_id: admin_set_id,
                        submitter_email: submitter_email)
  end
  let(:ingest_type) { 'example_ingest_type' }
  let(:source_location) { 'path/to/batch_manifest.csv' }
  let(:admin_set_id) { 'gid://internal/AdminSet/default' }
  let(:submitter_email) { 'archivist1@example.com' }
  let(:batch) { batch_runner.batch }

  describe 'run' do
    xit 'reads and enqueues a batch' do
    end
  end

  describe 'initialize_batch' do
    it 'persists the batch' do
      expect { batch_runner.initialize_batch }.to change(Hyrax::BatchIngest::Batch, :count).by(1)
      expect(batch.reload).to be_persisted
    end

    it 'sets the batch status to received' do
      batch_runner.initialize_batch
      batch.reload
      expect(batch.status).to eq 'received'
    end

    it 'fails the batch if error encountered' do
      allow(batch_runner.batch).to receive(:save!).and_raise(ActiveRecord::ActiveRecordError, "Error persisting batch")
      batch_runner.initialize_batch
      batch.reload
      expect(batch.status).to eq 'failed'
      expect(batch.error).not_to be_blank
    end
  end

  # describe 'read' do
  # end
  #
  # describe 'enqueue' do
  # end
end
