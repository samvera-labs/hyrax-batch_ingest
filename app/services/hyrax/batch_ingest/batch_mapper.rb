# frozen_string_literal: true
module Hyrax
  module BatchIngest
    class BatchMapper
      def initialize(batch_item, config)
        @config = config
        @batch_item = batch_item
      end

      def map
        {}
      end
    end
  end
end
