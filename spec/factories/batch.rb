FactoryBot.define do
  factory :batch do
    admin_set_id { 'gid://internal/AdminSet/default' }
    submitter_email { 'archivist1@example.com' }
    source_location { 'path/to/batch_manifest.csv' }
    status { :complete }
    error_message
    batch_items
  end
end
