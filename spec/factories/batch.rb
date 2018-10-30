# frozen_string_literal: true

FactoryBot.define do
  factory :batch, class: Hyrax::BatchIngest::Batch do
    admin_set_id { 'gid://internal/AdminSet/default' }
    submitter_email { 'archivist1@example.com' }
    source_location { 'path/to/batch_manifest.csv' }
    status { :complete }
  end
end
