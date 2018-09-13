module Hyrax
  module BatchIngest
    class BatchItem < ActiveRecord::Base
      # SCHEMA: :id, :batch_id, :id_within_batch, :attribute_hash,
      #         :status, :error, :created_item_id, :timestamps

      belongs_to :batch

      validates_each :attribute_hash do |record, attr, value|
        result = batch.class.validator.(value).inspect
        record.errors.add(attr, result.messages(full: true)) if result.messages.present?
      end

      def process
        batch.class.processor.new.call(attribute_hash)
      end
    end
  end
end
