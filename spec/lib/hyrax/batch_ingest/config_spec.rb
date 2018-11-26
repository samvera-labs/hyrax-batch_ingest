# frozen_string_literal: true
require 'rails_helper'
require 'hyrax/batch_ingest/config'

RSpec.describe Hyrax::BatchIngest::Config do
  let(:config_file_path) { File.join(fixture_path, 'example_config.yml') }
  let(:config) { described_class.new(config_file_path) }

  describe 'ingest_types' do
    it 'returns an array of IngestTypeConfig instances' do
      expect(config.ingest_types.values).to all be_a(Hyrax::BatchIngest::IngestTypeConfig)
    end
  end

  describe 'ingest_type' do
    context 'when given a recognized ingest type' do
      it 'returns the IngestConfigType instance' do
        expect(config.ingest_type(:example_ingest_type)).to be_a Hyrax::BatchIngest::IngestTypeConfig
        expect(config.ingest_type(:other_ingest_type)).to be_a Hyrax::BatchIngest::IngestTypeConfig
      end
    end

    context 'when given an unrecognized ingest type' do
      it 'raises an UnrecognizedIngestType error' do
        expect { config.ingest_type(:not_an_ingest_type) }.to raise_error Hyrax::BatchIngest::UnrecognizedIngestTypeError
      end
    end
  end

  describe '#add_ingest_type_config' do
    before do
      config.add_ingest_type_config(
        'foo',
        reader: 'FooReader',
        ingester: 'FooIngester'
      )
    end

    it 'allows adding ingest type config at runtime' do
      expect(config.ingest_types[:foo]).to be_a Hyrax::BatchIngest::IngestTypeConfig
    end

    context 'with additional config for custom Reader and Ingester classes' do
      before do
        config.add_ingest_type_config(
          'bar',
          reader: 'BarReader',
          reader_options: {
            opt_1: "pizza",
            opt_2: "cookies"
          },
          ingester: 'BarIngester',
          ingester_options: "single value param"
        )
      end

      it 'allows specifying additional config for Reader and Ingester classes' do
        expect(config.ingest_types[:bar]).to be_a Hyrax::BatchIngest::IngestTypeConfig
      end
    end
  end

  context 'with an non-existent config file' do
    let(:config_file_path) { 'not_a_file' }
    it 'raises a ConfigFileNotFound error' do
      expect { config }.to raise_error Hyrax::BatchIngest::ConfigFileNotFoundError
    end
  end
end
