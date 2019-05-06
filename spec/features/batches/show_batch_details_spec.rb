# frozen_string_literal: true
require 'rails_helper'

describe 'Show Batches Data', type: :feature do
  context 'as a Batch Ingest Admin User' do
    let(:admin) { create(:admin) }
    before { login_as admin }

    describe 'default view' do
      # make a list of batch items, 1-3 for each different status.
      let(:batch_items) do
        Hyrax::BatchIngest::BatchItem::STATUSES.map do |status|
          build_list(:batch_item, 2, status: status)
        end.flatten
      end

      let(:completed_batch_items) { batch_items.select { |batch_item| batch_item.status == 'completed' } }

      let(:batch) { create(:batch, batch_items: batch_items) }
      before do
        visit batch_path(id: batch.id)
      end

      it 'show batch details and list of batch items' do
        expect(page).to have_header "Batch Details"
        # TODO: expect to see other details of the batch record.
        expect(page).to only_have_batch_item_rows batch.batch_items
      end

      it 'has links to repo objects for completed batch items' do
        completed_batch_items.each do |batch_item|
          expect(page).to have_link(href: /\/concern\/generic_works\/#{batch_item.repo_object_id}/)
        end
      end
    end
  end
end
