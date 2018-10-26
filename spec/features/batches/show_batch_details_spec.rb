# frozen_string_literal: true
require 'rails_helper'

describe 'Show Batches Data', type: :feature do
  context 'as a Batch Ingest Admin User' do
    let(:admin) { create(:admin) }
    before { login_as admin }

    describe 'default view' do
      let(:batch) { create(:batch, batch_items: build_list(:batch_item, 5)) }
      before { visit "/batches/#{batch.id}" }

      it 'show batch details and list of batch items' do
        expect(page).to have_header "Batch Details"
        # TODO: expect to see other details of the batch record.
        expect(page).to only_have_batch_item_rows batch.batch_items
      end
    end
  end
end
