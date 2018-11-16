# frozen_string_literal: true
require 'rails_helper'
require 'hyrax/batch_ingest/spec/shared_specs'

describe Hyrax::BatchIngest::BatchReader do
  before(:all) do
    class ExampleReader < Hyrax::BatchIngest::BatchReader
      protected

        def perform_read
          raise Hyrax::BatchIngest::ReaderError.new("Unparsable!") if source_location == "invalid_source"
          @batch_items = [Hyrax::BatchIngest::BatchItem.new(id_within_batch: '1', source_data: '{}', status: 'initialized')]
        end
    end
  end

  after(:all) do
    Object.send(:remove_const, :ExampleReader)
  end

  let(:reader_class) { ExampleReader }
  let(:source_location) { "path/to/source" }
  let(:invalid_source_location) { "invalid_source" }

  it_behaves_like 'a Hyrax::BatchIngest::BatchReader'
end
