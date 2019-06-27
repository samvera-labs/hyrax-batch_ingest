# frozen_string_literal: true
require 'rails_helper'

describe 'Batch Summary', type: :feature do
  context 'as a Batch Ingest Admin User' do
    # build a big random list of batch items
    let(:batch_items) { Array.new(rand(100..1000)) { build(:batch_item) } }

    # calculate some totals expected for the summary
    let(:num_finished) do
      batch_items.select { |batch_item| batch_item.status.in? ['completed', 'failed', 'expunged'] }.count
    end
    let(:num_remaining) { batch_items.count - num_finished }
    let(:num_errors) { batch_items.select(&:error).count }
    let(:num_objects_ingested) { batch_items.select(&:repo_object_id).count }

    # create a batch with the batch items
    let(:batch) { create(:batch, batch_items: batch_items) }

    # Go to the summary page before each example
    before do
      login_as create(:admin)
      visit summary_batch_path(id: batch.id)
    end

    it 'shows the number of batch items finished' do
      expect(page).to have_content "#{num_finished} Batch Items Finished"
    end

    it 'shows the number of batch items remaining' do
      expect(page).to have_content "#{num_remaining} Batch Items Remaining"
    end

    it 'shows the number of objects ingested (according to BatchItem#repo_object_id)' do
      expect(page).to have_content "#{num_objects_ingested} Objects Ingested"
    end

    it 'shows the number of errors' do
      expect(page).to have_content "#{num_errors} Errors"
    end
  end
end
