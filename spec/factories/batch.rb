# frozen_string_literal: true

FactoryBot.define do
  factory :batch, class: Hyrax::BatchIngest::Batch do
    admin_set_id { nil }
    source_location { 'path/to/batch_manifest.csv' }
    status { 'completed' }
    sequence(:submitter_email) { |n| "batch_submitter_#{n}@example.org" }
    error {}
    ingest_type { 'example_ingest_type' }

    after(:build) do |batch, evaluator|
      evaluator.batch_items.each { |batch_item| batch_item.batch = batch }
    end

    after(:create) do |batch, evaluator|
      evaluator.batch_items.each { |batch_item| batch_item.batch = batch }
    end

    factory :initialized_batch do
      status { 'received' }
    end

    factory :accepted_batch do
      status { 'accepted' }
    end

    factory :enqueued_batch do
      status { 'enqueued' }
    end

    factory :running_batch do
      status { 'enqueued' }
    end
  end
end
