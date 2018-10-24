require 'rails_helper'
require 'hyrax/batch_ingest/config'

RSpec.describe Hyrax::BatchIngest::Config do
  describe '.new' do
    let(:config) { described_class.new(ingest_type: 'example_ingest_type', config_file_path: config_file_path) }

    context 'with a valid config file' do
      let(:config_file_path) { File.join(fixture_path, 'example_config', 'valid_config.yml') }
      it 'loads without error' do
        expect{ config }.to_not raise_error
      end

      describe 'reader' do
        it 'returns the reader value for the ingest type' do
          expect(config.reader).to eq 'ExampleReader'
        end
      end

      describe 'mapper' do
        it 'returns the mapper value for the ingest type' do
          expect(config.mapper).to eq 'ExampleMapper'
        end
      end

      describe 'source_validator' do
        it 'returns the source_validator for the ingest type' do
          expect(config.source_validator).to eq 'ExampleSourceValidator'
        end
      end
    end

    context 'with an non-existent config file' do
      let(:config_file_path) { 'not_a_file' }
      it 'raises a InvalidConfig error' do
        expect{ config }.to raise_error Hyrax::BatchIngest::Error::MissingConfig
      end
    end
  end
end
