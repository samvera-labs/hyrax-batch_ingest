# frozen_string_literal: true

require 'spec_helper'
require 'hyrax/batch_ingest/ingest_type_config'

RSpec.describe Hyrax::BatchIngest::IngestTypeConfig do
  describe '.new' do
    context 'with invalid options' do
      let(:ingest_type_config) { described_class.new('example_ingest_type', blerg: "this is an invalid option") }
      it 'raises an InvalidIngestTypeConfigOption error' do
        expect { ingest_type_config }.to raise_error Hyrax::BatchIngest::InvalidConfigOptionsError
      end
    end

    context 'when missing required options' do
      let(:ingest_type_config) { described_class.new('example_ingest_type', reader: 'ExampleReader') }
      it 'raises a MissingRequiredConfigOptionsError error' do
        expect { ingest_type_config }.to raise_error Hyrax::BatchIngest::MissingRequiredConfigOptionsError
      end
    end
  end

  context 'when the specified classes exist' do
    before do
      # some test classes
      class ExampleReader; end
      class ExampleIngester; end
    end

    let(:ingest_type_config) do
      described_class.new('example_ingest_type', reader: 'ExampleReader',
                                                 ingester: 'ExampleIngester',
                                                 label: 'Example Batch Ingest')
    end

    describe '#reader' do
      it 'returns the value of the :reader config option' do
        expect(ingest_type_config.reader).to eq ExampleReader
      end
    end

    describe '#ingester' do
      it 'returns the ingester value for the ingest type' do
        expect(ingest_type_config.ingester).to eq ExampleIngester
      end
    end

    describe '#label' do
      it 'returns the label for the ingest type' do
        expect(ingest_type_config.label).to eq 'Example Batch Ingest'
      end
    end

    context 'when optional reader_options and ingester_options options are specified' do
      let(:reader_options) { { 'opt1' => "reader option 1", 'opt2' => "reader option 1" } }
      let(:ingester_options) { { 'opt1' => 'ingest option 1' } }
      let(:ingest_type_config) do
        described_class.new('example_ingest_type', reader: 'ExampleReader',
                                                   reader_options: reader_options,
                                                   ingester: 'ExampleIngester',
                                                   ingester_options: ingester_options,
                                                   label: 'Example Batch Ingest')
      end

      describe '#reader_options' do
        it 'returns the reader options' do
          expect(ingest_type_config.reader_options).to eq reader_options
        end
      end

      describe '#ingester_options' do
        it 'returns the optional config values' do
          expect(ingest_type_config.ingester_options).to eq ingester_options
        end
      end
    end

    # clean up test classes
    after do
      Object.send(:remove_const, :ExampleReader)
      Object.send(:remove_const, :ExampleIngester)
    end
  end

  context 'when the specified classes do not exist' do
    let(:ingest_type_config) do
      described_class.new('example_ingest_type', reader: 'ClassDoesNotExist',
                                                 ingester: 'ClassDoesNotExist')
    end

    describe '#reader' do
      it 'raises a Hyrax::BatchIngest::ReaderClassNotFoundError' do
        expect { ingest_type_config.reader }.to raise_error Hyrax::BatchIngest::ReaderClassNotFoundError
      end
    end

    describe '#ingester' do
      it 'raises a Hyrax::BatchIngest::ReaderClassNotFoundError' do
        expect { ingest_type_config.ingester }.to raise_error Hyrax::BatchIngest::IngesterClassNotFoundError
      end
    end
  end
end
