# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::BatchIngest::BatchRunner do
  describe 'initialize' do
    let(:batch) { FactoryBot.build(:batch) }
    let(:ingest_type) { 'example_ingest_type' }
    let(:source_location) { 'path/to/batch_manifest.csv' }
    let(:admin_set_id) { 'gid://internal/AdminSet/default' }
    let(:submitter_email) { 'archivist1@example.com' }
    let(:batch_arg_runner) { described_class.new(batch: batch) }
    let(:attribute_arg_runner) do
      described_class.new(ingest_type: ingest_type,
                          source_location: source_location,
                          admin_set_id: admin_set_id,
                          submitter_email: submitter_email)
    end
    let(:attribute_and_batch_arg_runner) do
      described_class.new(batch: batch,
                          ingest_type: ingest_type,
                          source_location: source_location,
                          admin_set_id: admin_set_id,
                          submitter_email: submitter_email)
    end

    it 'can be passed a batch' do
      expect(batch_arg_runner.batch).to eq batch
    end

    it 'can be passed the parameters for a batch' do
      expect(attribute_arg_runner.batch.ingest_type).to eq ingest_type
      expect(attribute_arg_runner.batch.source_location).to eq source_location
      expect(attribute_arg_runner.batch.admin_set_id).to eq admin_set_id
      expect(attribute_arg_runner.batch.submitter_email).to eq submitter_email
    end

    it 'prefers batch paramter' do
      expect(attribute_and_batch_arg_runner.batch).to eq batch
    end
  end

  describe 'run' do
    xit 'reads and enqueues a batch' do
    end
  end

  describe 'initialize_batch' do
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

  describe 'read' do
    let(:batch_runner) { described_class.new(batch: batch) }
    let(:batch) { FactoryBot.build(:initialized_batch) }
    let(:submitter_email) { batch.submitter_email }

    it 'raises ArguementError if batch not persisted yet' do
      expect { batch_runner.read }.to raise_error(ArgumentError)
    end

    context 'with batch initialized' do
      let(:batch) { FactoryBot.create(:initialized_batch) }
      let(:config) { instance_double(Hyrax::BatchIngest::IngestTypeConfig, reader: reader_class) }
      let(:reader_class) { double("ReaderClass") }
      let(:reader) { double("BatchReader") }
      let(:batch_items) { [FactoryBot.build(:batch_item), FactoryBot.build(:batch_item)] }

      before do
        allow(batch_runner).to receive(:config).and_return(config)
        allow(reader_class).to receive(:new).with(batch.source_location).and_return(reader)
        allow(reader).to receive(:batch_items).and_return(batch_items)
        allow(reader).to receive(:submitter_email).and_return(submitter_email)
        batch_runner.initialize_batch
      end

      it 'reads the batch items from the reader' do
        expect { batch_runner.read }.to change(Hyrax::BatchIngest::BatchItem, :count).by(2)
      end

      it 'sets the batch status to accepted' do
        batch_runner.read
        batch.reload
        expect(batch.status).to eq 'accepted'
      end

      context 'submitter email' do
        it 'sets when batch is missing email and reader has email' do
          batch.submitter_email = nil
          batch_runner.read
          batch.reload
          expect(batch.submitter_email).to eq submitter_email
        end

        it 'stays the same when batch has email and reader has same email' do
          batch_runner.read
          batch.reload
          expect(batch.submitter_email).to eq submitter_email
        end

        it 'stays the same when batch has email and reader is missing email' do
          allow(reader).to receive(:submitter_email).and_return(nil)
          batch_runner.read
          batch.reload
          expect(batch.submitter_email).to eq submitter_email
        end

        it 'fails when batch different email than reader' do
          allow(reader).to receive(:submitter_email).and_return("different_email@example.com")
          batch_runner.read
          batch.reload
          expect(batch.status).to eq 'failed'
          expect(batch.error).not_to be_blank
        end
      end

      context 'errors' do
        context 'with ReaderError' do
          let(:config) { instance_double(Hyrax::BatchIngest::IngestTypeConfig, reader: bad_reader_class) }
          let(:bad_reader_class) { double("ReaderClass") }
          let(:bad_reader) { double("BatchReader") }

          before do
            allow(bad_reader_class).to receive(:new).with(batch.source_location).and_return(bad_reader)
            allow(bad_reader).to receive(:batch_items).and_raise(Hyrax::BatchIngest::ReaderError, "Invalid batch")
          end

          it 'fails the batch' do
            batch_runner.read
            batch.reload
            expect(batch.status).to eq 'failed'
            expect(batch.error).not_to be_blank
          end
        end

        context 'with AtiveRecordError' do
          it 'fails the batch' do
            allow(batch).to receive(:save!).and_raise(ActiveRecord::ActiveRecordError, "Database error")
            batch_runner.read
            batch.reload
            expect(batch.status).to eq 'failed'
            expect(batch.error).not_to be_blank
          end
        end
      end
    end
  end

  describe 'enqueue' do
    let(:batch_runner) { described_class.new(batch: batch) }
    let(:batch) { FactoryBot.create(:initialized_batch) }

    it 'raises ArguementError if batch has not been accepted' do
      expect { batch_runner.enqueue }.to raise_error(ArgumentError)
    end

    context 'with batch accepted' do
      let(:batch) { FactoryBot.create(:accepted_batch, batch_items: batch_items) }
      let(:batch_items) { [FactoryBot.build(:batch_item), FactoryBot.build(:batch_item)] }

      it 'enqueues the batch items from the reader' do
        batch_runner.enqueue
        expect(Hyrax::BatchIngest::BatchItemProcessingJob).to have_been_enqueued.with(batch_items[0])
        expect(Hyrax::BatchIngest::BatchItemProcessingJob).to have_been_enqueued.with(batch_items[1])
      end

      it 'sets the batch status to enqueued' do
        batch_runner.enqueue
        batch.reload
        expect(batch.status).to eq 'enqueued'
      end

      it 'sets the status of the batch items to enqueued' do
        batch_runner.enqueue
        batch.reload
        expect(batch.batch_items.all? { |item| item.status == 'enqueued' }).to eq true
      end

      context 'errors' do
        context 'with AtiveRecordError' do
          before do
            allow(batch).to receive(:update).and_call_original
            allow(batch).to receive(:update).with(status: 'enqueued').and_raise(ActiveRecord::ActiveRecordError, "Database error")
          end

          it 'fails the batch' do
            batch_runner.enqueue
            batch.reload
            expect(batch.status).to eq 'failed'
            expect(batch.error).not_to be_blank
          end
        end
      end
    end
  end
end
