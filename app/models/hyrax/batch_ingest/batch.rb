module Hyrax
  module BatchIngest
    class Batch < ActiveRecord::Base
      # SCHEMA: :id, :submitter, :filename, :timestamps
      has_many :batch_items

      class_attribute :reader # Reads the batch and creates batch items
      class_attribute :item_validator # Dry::Validator.Schema
      class_attribute :item_processor # Dry::Transaction

      def initialize(filename: filename, submitter: submitter)
        super.tap do |batch|
          batch.batch_items = reader.read(file)
        end
      end

      after_save do |batch|
        batch.batch_items.each do |batch_item|
          BatchItemProcessingJob.perform_later(batch_item)
        end
      end
    end
  end
end
