FactoryBot.define do
  factory :batch_item do
    batch
    name { 'Row #2' }
    source_data { '{ title: ["Title"], creator: ["Jane Doe"], keyword: ["test"]}' }
    source_location { 'path/to/batch_manifest.csv' }
    status { :complete }
    error_message
  end
end
