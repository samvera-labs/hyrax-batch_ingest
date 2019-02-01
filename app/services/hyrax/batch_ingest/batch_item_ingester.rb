# frozen_string_literal: true
module Hyrax
  module BatchIngest
    class BatchItemIngester
      attr_reader :batch_item, :options

      def initialize(batch_item, opts = {})
        @batch_item = batch_item
        @options = opts || {}
      end

      def ingest
        raise Hyrax::BatchIngest::IngesterError.new("Cannot use abstract BatchItemIngester class.")
      end
    end
  end
end
