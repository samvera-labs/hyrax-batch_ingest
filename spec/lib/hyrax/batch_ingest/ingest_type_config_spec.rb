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
      class ExampleMapper; end
    end

    let(:ingest_type_config) do
      described_class.new('example_ingest_type', reader: 'ExampleReader',
                                                 mapper: 'ExampleMapper',
                                                 label: 'Example Mapper')
    end

    describe '#reader' do
      it 'returns the value of the :reader config option' do
        expect(ingest_type_config.reader).to eq ExampleReader
      end
    end

    describe 'mapper' do
      it 'returns the mapper value for the ingest type' do
        expect(ingest_type_config.mapper).to eq ExampleMapper
      end
    end

    describe '#label' do
      it 'returns the label for the ingest type' do
        expect(ingest_type_config.label).to eq 'Example Mapper'
      end
    end

    # clean up test classes
    after do
      Object.send(:remove_const, :ExampleReader)
      Object.send(:remove_const, :ExampleMapper)
    end
  end

  context 'when the specified classes do not exist' do
    let(:ingest_type_config) do
      described_class.new('example_ingest_type', reader: 'ClassDoesNotExist',
                                                 mapper: 'ClassDoesNotExist')
    end

    describe '#reader' do
      it 'raises a Hyrax::BatchIngest::ReaderClassNotFoundError' do
        expect { ingest_type_config.reader }.to raise_error Hyrax::BatchIngest::ReaderClassNotFoundError
      end
    end

    describe '#mapper' do
      it 'raises a Hyrax::BatchIngest::ReaderClassNotFoundError' do
        expect { ingest_type_config.mapper }.to raise_error Hyrax::BatchIngest::MapperClassNotFoundError
      end
    end
  end
end
