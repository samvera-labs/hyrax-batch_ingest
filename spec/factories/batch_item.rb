# frozen_string_literal: true

FactoryBot.define do
  factory :batch_item do
    batch
    id_within_batch
    source_data { '{ title: ["Title"], creator: ["Jane Doe"], keyword: ["test"]}' }
    source_location { 'path/to/batch_manifest.csv' }
    status { :complete }
    error
    object_id
  end
end
