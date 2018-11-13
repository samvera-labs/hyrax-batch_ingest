# frozen_string_literal: true
module Hyrax
  module BatchIngest
    class BatchMapper
      def initialize(batch_item)
        @batch_item = batch_item
      end

      def attributes
        {}
      end

      def self.actor
        Hyrax::CurationConcern.actor
      end

      private

        def config
          @config ||= Hyrax::BatchIngest.config.ingest_types[batch_item.batch.ingest_type.to_sym]
        end
    end
  end
end
