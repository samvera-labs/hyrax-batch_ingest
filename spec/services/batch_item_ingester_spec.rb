# frozen_string_literal: true
require 'rails_helper'
require 'hyrax/batch_ingest/spec/shared_specs'

describe Hyrax::BatchIngest::BatchItemIngester do
  before(:all) do
    class ExampleBatchItemIngester < Hyrax::BatchIngest::BatchItemIngester
      def ingest
        ActiveFedora::Base.create
      end
    end
  end

  after(:all) do
    Object.send(:remove_const, :ExampleBatchItemIngester)
  end

  let(:ingester_class) { ExampleBatchItemIngester }
  let(:batch_item) { FactoryBot.build(:batch_item) }

  it_behaves_like 'a Hyrax::BatchIngest::BatchItemIngester'
end
