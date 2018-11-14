# frozen_string_literal: true
require 'rails_helper'

describe Hyrax::BatchIngest::BatchItemIngester do
  let(:ingester) { described_class.new(batch_item) }
  let(:batch_item) { FactoryBot.build(:batch_item) }

  describe '#initialize' do
    it 'stores the batch item' do
      expect(ingester.batch_item).to eq batch_item
    end
  end

  describe '#ingest' do
    it 'throws an exception' do
      expect { ingester.ingest }.to raise_error(Hyrax::BatchIngest::IngesterError)
    end
  end
end
