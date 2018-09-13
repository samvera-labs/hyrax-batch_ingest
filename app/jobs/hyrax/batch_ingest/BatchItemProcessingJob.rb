module Hyrax
  module BatchIngest
    class BatchItemProcessingJob < ActiveJob::Base
      def perform(batch_item)
        batch_item.process
      end
    end
  end
end
