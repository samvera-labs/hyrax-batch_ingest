# frozen_string_literal: true
require 'rails_helper'

describe Hyrax::BatchIngest::BatchItemProcessingJob do
  let(:batch) { FactoryBot.create(:enqueued_batch, batch_items: [batch_item]) }
  let(:batch_item) { FactoryBot.build(:batch_item, status: 'enqueued', object_id: nil) }
  let(:config) { instance_double(Hyrax::BatchIngest::IngestTypeConfig, ingester: ingester_class) }
  let(:ingester_class) { double("IngesterClass") }
  let(:ingester) { double("BatchItemIngester") }
  let(:work) { double("work", id: 'new_object') }
  let(:job) { described_class.new(batch_item) }

  before do
    allow(job).to receive(:config).and_return(config)
    allow(ingester_class).to receive(:new).with(batch_item).and_return(ingester)
    allow(ingester).to receive(:ingest).and_return(work)
  end

  describe '#perform' do
    let!(:batch) { FactoryBot.create(:enqueued_batch, batch_items: [batch_item]) }

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
        job.perform_now
        expect(batch_item.reload.status).to eq 'failed'
        expect(batch_item.error).not_to be_blank
      end

      it 'sets the batch to completed if completed' do
        job.perform_now
        expect(batch.reload.status).to eq 'completed'
      end

      it 'does nothing if batch is not completed' do
        batch = FactoryBot.create(:running_batch, batch_items: [batch_item, FactoryBot.build(:batch_item, status: 'enqueued')])
        job.perform_now
        expect(batch.reload.status).to eq 'running'
      end
    end
  end

  describe 'before_perform' do
    let(:batch) { FactoryBot.create(:enqueued_batch, batch_items: [batch_item]) }

    it 'sets the batch and batch_item to running' do
      allow(batch).to receive(:update).and_call_original
      allow(batch_item).to receive(:update).and_call_original
      job.perform_now
      expect(batch).to have_received(:update).with(status: 'running')
      expect(batch_item).to have_received(:update).with(status: 'running')
    end
  end

  describe 'after_perform' do
    context 'batch completed' do
      it 'sets the batch to completed if completed' do
        batch = FactoryBot.create(:running_batch, batch_items: [batch_item])
        job.perform_now
        # Make sure that after_perform was run and not the rescue
        expect(batch_item.reload.status).not_to eq 'failed'
        expect(batch.reload.status).to eq 'completed'
      end

      it 'sends batch completed email' do
        expect { job.perform_now }
          .to have_enqueued_job(ActionMailer::Parameterized::DeliveryJob)
          .with('Hyrax::BatchIngest::BatchCompleteMailer', 'batch_completed_successfully', 'deliver_now', batch: batch)
      end
    end

    context 'batch completed with item errors' do
      let(:batch_item) { FactoryBot.build(:batch_item, status: 'enqueued', error: 'Error') }

      it 'sends batch completed email if errors exist' do
        expect { job.perform_now }
          .to have_enqueued_job(ActionMailer::Parameterized::DeliveryJob)
          .with('Hyrax::BatchIngest::BatchCompleteMailer', 'batch_completed_with_errors', 'deliver_now', batch: batch)
      end
    end

    context 'batch not completed' do
      it 'does nothing if batch is not completed' do
        batch = FactoryBot.create(:running_batch, batch_items: [batch_item, FactoryBot.build(:batch_item, status: 'enqueued')])
        job.perform_now
        # Make sure that after_perform was run and not the rescue
        expect(batch_item.reload.status).not_to eq 'failed'
        expect(batch.reload.status).to eq 'running'
      end
    end
  end
end
