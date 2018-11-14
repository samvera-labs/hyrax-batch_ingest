# frozen_string_literal: true
require 'rails_helper'

describe Hyrax::BatchIngest::BatchItemProcessingJob do
  let!(:batch) { FactoryBot.create(:enqueued_batch, batch_items: [batch_item]) }
  let(:batch_item) { FactoryBot.build(:batch_item, status: 'enqueued', object_id: nil) }

  describe '#perform' do
    let(:config) { instance_double(Hyrax::BatchIngest::IngestTypeConfig, ingester: ingester_class) }
    let(:ingester_class) { double("IngesterClass") }
    let(:ingester) { double("BatchItemIngester") }
    let(:work) { double("work", id: 'new_object') }
    let(:job) { described_class.new }

    before do
      allow(job).to receive(:config).and_return(config)
      allow(ingester_class).to receive(:new).with(batch_item).and_return(ingester)
      allow(ingester).to receive(:ingest).and_return(work)
    end

    it 'runs the ingester' do
      job.perform(batch_item)
      expect(ingester).to have_received(:ingest)
    end

    it 'sets the BatchItem status to completed' do
      job.perform(batch_item)
      expect(batch_item.reload.status).to eq 'completed'
    end

    it 'updates the BatchItem with the created object id' do
      job.perform(batch_item)
      expect(batch_item.reload.object_id).to eq work.id
    end

    context 'with exception' do
      before do
        allow(ingester).to receive(:ingest).and_raise(Hyrax::BatchIngest::IngesterError.new("Error"))
      end

      it 'sets the batch item to failed' do
        described_class.perform_now(batch_item)
        expect(batch_item.reload.status).to eq 'failed'
        expect(batch_item.error).not_to be_blank
      end

      it 'sets the batch to completed if completed' do
        described_class.perform_now(batch_item)
        expect(batch.reload.status).to eq 'completed'
      end

      it 'does nothing if batch is not completed' do
        batch = FactoryBot.create(:running_batch, batch_items: [batch_item, FactoryBot.build(:batch_item, status: 'enqueued')])
        described_class.perform_now(batch_item)
        expect(batch.reload.status).to eq 'running'
      end
    end
  end

  describe 'before_perform' do
    let(:batch) { FactoryBot.create(:enqueued_batch, batch_items: [batch_item]) }

    it 'sets the batch and batch_item to running' do
      allow(batch).to receive(:update).and_call_original
      allow(batch_item).to receive(:update).and_call_original
      described_class.perform_now(batch_item)
      expect(batch).to have_received(:update).with(status: 'running')
      expect(batch_item).to have_received(:update).with(status: 'running')
    end
  end

  describe 'after_perform' do
    let(:batch) { FactoryBot.create(:running_batch, batch_items: [batch_item]) }

    it 'sets the batch to completed if completed' do
      described_class.perform_now(batch_item)
      expect(batch.reload.status).to eq 'completed'
    end

    it 'does nothing if batch is not completed' do
      batch = FactoryBot.create(:running_batch, batch_items: [batch_item, FactoryBot.build(:batch_item, status: 'enqueued')])
      described_class.perform_now(batch_item)
      expect(batch.reload.status).to eq 'running'
    end
  end
end
