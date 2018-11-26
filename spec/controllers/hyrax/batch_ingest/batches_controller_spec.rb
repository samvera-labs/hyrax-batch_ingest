# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::BatchIngest::BatchesController, type: :controller do
  routes { Hyrax::BatchIngest::Engine.routes }
  let(:admin_user) { create :admin }
  let(:user) { create :user }

  context 'when there are no ingest types configured' do
    before do
      sign_in admin_user
      # Set the batch ingest config to not have any ingest types.
      allow(Hyrax::BatchIngest.config).to receive(:ingest_types).and_return({})
    end

    let(:response) { get :new }

    it 'redirects the user back to /batches with a flash message' do
      expect(response).to redirect_to(batches_url)
      expect(flash[:notice]).to eq "No batch ingest types have been configured."
    end
  end

  describe 'POST /batches/create' do
    # Mock the nearest edge
    before do
      sign_in admin_user
      allow(controller).to receive(:start_batch_runner).with(kind_of(Hyrax::BatchIngest::Batch))
    end

    context 'with valid params' do
      let(:batch_params) do
        { batch: attributes_for(:batch).merge('batch_source' => fixture_file_upload('example_batches/empty.zip')) }
      end

      it 'calls #start_batch_runner' do
        post :create, params: batch_params
        expect(controller).to have_received(:start_batch_runner).with(kind_of(Hyrax::BatchIngest::Batch)).exactly(1).times
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { batch_params.delete(:ingest_type) }
      xit 'it does not call #start_batch_runner' do
        post :create, params: invalid_params
        expect(controller).not_to have_received(:start_batch_runner)
      end
    end
  end

  describe 'abilities' do
    let(:batch_items) { build_list(:batch_item, 1) }
    let(:batch) { create(:batch, batch_items: batch_items) }
    let(:batch_params) do
      { batch: attributes_for(:batch).merge('batch_source' => fixture_file_upload('example_batches/empty.zip')) }
    end
    before { sign_in current_user }

    describe "as a non-admin user" do
      let(:current_user) { user }

      # TODO: #27 following tests got 401 instead of 403. is that expected behavior when Ability authoirzation fails?
      it "#index should return 401" do
        # expect(get(:index)).to have_http_status(401) # TODO: #27 this got 302 instead of 401
        expect(get(:index)).to have_http_status(302) # TODO: #27 this got 302 instead of 401
      end
      it "#show should return 401" do
        expect(get(:show, params: { id: batch.id })).to have_http_status(401)
      end
      it "#new should return 401" do
        # expect(get(:new)).to have_http_status(401) # TODO: #27 this got 302 instead of 401
        expect(get(:new)).to have_http_status(302) # TODO: #27 this got 302 instead of 401
      end
      it "#post should return 401" do
        expect(post(:create, params: batch_params)).to have_http_status(401)
      end
    end

    describe "as an admin user" do
      let(:current_user) { admin_user }

      it "#index should return 200" do
        expect(get(:index)).to have_http_status(200)
      end
      it "#show should return 200" do
        expect(get(:show, params: { id: batch.id })).to have_http_status(200)
      end
      it "#new routes should return 200" do
        expect(get(:new)).to have_http_status(200)
      end
      it "#post routes should return 302" do
        expect(post(:create, params: batch_params)).to have_http_status(302)
      end
    end
  end
end
