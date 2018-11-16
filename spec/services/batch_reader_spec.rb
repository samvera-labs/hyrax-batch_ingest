# frozen_string_literal: true
require 'rails_helper'

describe Hyrax::BatchIngest::BatchReader do
  let(:reader) { described_class.new(source_location) }
  let(:source_location) { 'path/to/batch/source' }

  describe '#initialize' do
    it 'stores the source_location' do
      expect(reader.source_location).to eq source_location
    end
  end

  describe '#submitter_email' do
    it 'throws an exception' do
      expect { reader.submitter_email }.to raise_error(Hyrax::BatchIngest::ReaderError)
    end
  end

  describe '#batch_items' do
    it 'throws an exception' do
      expect { reader.batch_items }.to raise_error(Hyrax::BatchIngest::ReaderError)
    end
  end
end
