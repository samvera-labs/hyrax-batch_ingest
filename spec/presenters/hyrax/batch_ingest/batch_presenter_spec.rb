# frozen_string_literal: true
require 'rails_helper'
require 'hyrax/batch_ingest/batch_presenter'

RSpec.describe Hyrax::BatchIngest::BatchPresenter do
  let(:presenter) { described_class.new(batch) }
  describe '#status_css_class' do
    context 'when Batch status is "received"' do
      let(:batch) { build(:batch, status: 'received') }
      it 'returns the css class for the "received" status' do
        expect(presenter.status_css_class).to eq 'fa fa-info'
      end
    end

    context 'when Batch status is "accepted"' do
      let(:batch) { build(:batch, status: 'accepted') }
      xit 'returns the css class for the "accepted" status' do
        # TODO: expect the appropriate css class
      end
    end

    context 'when Batch status is "enqueued"' do
      let(:batch) { build(:batch, status: 'enqueued') }
      xit 'returns the css class for the "enqueued" status' do
        # TODO: expect the appropriate css class
      end
    end

    context 'when Batch status is "running"' do
      let(:batch) { build(:batch, status: 'running') }
      it 'returns the css class for the "running" status' do
        expect(presenter.status_css_class).to eq 'fa fa-refresh fa-sync'
      end
    end

    context 'when Batch status is "completed"' do
      let(:batch) { build(:batch, status: 'completed') }
      it 'returns the css class for the "completed" status' do
        expect(presenter.status_css_class).to eq 'fa fa-check-circle'
      end
    end

    context 'when Batch status is "failed"' do
      let(:batch) { build(:batch, status: 'failed') }
      it 'returns the css class for the "failed" status' do
        expect(presenter.status_css_class).to eq 'fa fa-exclamation-triangle'
      end
    end

    describe '#batch_item_presenters' do
      let(:batch) { build(:batch, batch_items: build_list(:batch_item, 5)) }
      it 'returns an array of BatchItemPresenter objects, each containing a BatchItem' do
        presenter.batch_item_presenters.each do |batch_item_presenter|
          expect(batch_item_presenter).to be_a Hyrax::BatchIngest::BatchItemPresenter
          expect(batch_item_presenter.batch_item).to be_a Hyrax::BatchIngest::BatchItem
        end
      end
    end
  end
end
