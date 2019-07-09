# frozen_string_literal: true

FactoryBot.define do
  factory :batch_item, class: Hyrax::BatchIngest::BatchItem do
    sequence(:id_within_batch) { |n| n }
    source_data { '{ title: ["Title"], creator: ["Jane Doe"], keyword: ["test"]}' }
    source_location { 'path/to/batch_manifest.csv' }
    status { Hyrax::BatchIngest::BatchItem::STATUSES.sample }
    repo_object_id { SecureRandom.uuid }
    error { nil }

    transient do
      ensure_valid { true }
    end

    after(:build) do |batch_item, evaluator|
      if evaluator.ensure_valid
        # If the batch item is completed, add an object id and a class name if
        # there isn't already one specified.
        if batch_item.status == 'completed'
          batch_item.repo_object_class_name ||= 'GenericWork'
        else
          batch_item.repo_object_id = nil
          batch_item.repo_object_class_name = nil
          if batch_item.status == 'failed'
            batch_item.error ||= [
              'What the fluff?',
              'All your base are blong to us',
              'What we have here is failure to communicate',
              'PC load letter',
              'Thaks Mario, but our princess is in another castle!'
            ].sample
          end
        end
      end
    end
  end
end
