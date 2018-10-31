# frozen_string_literal: true

FactoryBot.define do
  factory :batch_item, class: Hyrax::BatchIngest::BatchItem do
    sequence(:id_within_batch) { |n| n }
    source_data { '{ title: ["Title"], creator: ["Jane Doe"], keyword: ["test"]}' }
    source_location { 'path/to/batch_manifest.csv' }
    status { :complete }
    error { nil }
    object_id { '12345678' }
  end
end
