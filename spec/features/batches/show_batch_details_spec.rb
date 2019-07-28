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
          if status == 'completed'
            # Create real repo object for 'completed' batch items.
            build_list(:batch_item, rand(1..3), repo_object_id: ActiveFedora::Base.create.id, status: 'completed')
          else
            build_list(:batch_item, rand(1..3), status: status)
          end
        end.flatten
      end
      let(:completed_batch_items) { batch_items.select { |batch_item| batch_item.status == 'completed' } }
      let(:batch) { create(:batch, batch_items: batch_items) }
      let(:batch_presenter) { Hyrax::BatchIngest::BatchPresenter.new(batch) }
      before do
        visit batch_path(id: batch.id)
      end

      it 'shows the batch ID in the header' do
        expect(page).to have_header "Batch Ingest #{batch.id}"
      end

      it 'shows batch items related to the batch' do
        expect(page).to only_have_batch_item_rows batch.batch_items
      end

      it 'has links to repo objects for completed batch items' do
        completed_batch_items.each do |batch_item|
          expect(page).to have_link(href: /\/concern\/generic_works\/#{batch_item.repo_object_id}/)
        end
      end

      it 'shows the originally uploaded file name' do
        expect(page).to have_content batch.uploaded_filename
      end

      it 'shows the start time' do
        expect(page).to have_content batch_presenter.start_time
      end

      context 'when the batch is finished' do
        let(:batch) { create(:completed_batch) }
        it 'shows the end time' do
          expect(page).to have_content batch_presenter.end_time
        end
      end

      context 'when the batch is not yet finished' do
        let(:batch) { create(:running_batch) }
        it 'does not show the end time' do
          expect(page).not_to have_content 'Finished:'
        end
      end
    end
  end
end
