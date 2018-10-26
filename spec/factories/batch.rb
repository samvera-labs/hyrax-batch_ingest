# frozen_string_literal: true

FactoryBot.define do
  factory :batch, class: Hyrax::BatchIngest::Batch do
    admin_set_id { 'gid://internal/AdminSet/default' }
    source_location { 'path/to/batch_manifest.csv' }
    status { :complete }
    sequence(:submitter_email) { |n| "batch_submitter_#{n}@example.org" }
    error {}

    after(:build) do |batch, evaluator|
      evaluator.batch_items.each { |batch_item| batch_item.batch = batch }
    end

    after(:create) do |batch, evaluator|
      evaluator.batch_items.each { |batch_item| batch_item.batch = batch }
    end
  end
end
