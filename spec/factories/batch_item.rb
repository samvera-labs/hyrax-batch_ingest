# frozen_string_literal: true

FactoryBot.define do
  factory :batch_item, class: Hyrax::BatchIngest::BatchItem do
    sequence(:id_within_batch) { |n| n }
    source_data { '{ title: ["Title"], creator: ["Jane Doe"], keyword: ["test"]}' }
    source_location { 'path/to/batch_manifest.csv' }
    status { Hyrax::BatchIngest::BatchItem::STATUSES.sample }
    error { nil }

    after(:build) do |batch_item, _evaluator|
      # If the batch item is completed, add an object id and a class name if
      # there isn't already one specified.
      if batch_item.status == 'completed'
        batch_item.repo_object_id ||= SecureRandom.uuid
        batch_item.repo_object_class_name ||= 'GenericWork'
      end
    end
  end
end
