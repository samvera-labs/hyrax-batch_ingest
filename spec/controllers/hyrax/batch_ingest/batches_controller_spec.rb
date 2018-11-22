# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::BatchIngest::BatchesController, type: :controller do
  routes { Hyrax::BatchIngest::Engine.routes }
  let(:admin_user) { create :admin }
  before { sign_in admin_user }

  context 'when there are no ingest types configured' do
    before do
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
    before { allow(controller).to receive(:start_batch_runner).with(kind_of(Hyrax::BatchIngest::Batch)) }

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

  describe 'ability' do
    let(:batch) { FactoryBot.create(:batch) }
    let(:batch_params) do
      { batch: attributes_for(:batch).merge('batch_source' => fixture_file_upload('example_batches/empty.zip')) }
    end

    describe "as a non-admin user" do
      let(:current_user) { FactoryBot.create(:user) }
      it "all routes should return 403" do
        expect(get :index).to have_http_status(403)
        expect(get :show, id: batch.id).to have_http_status(403)
        expect(get :new).to have_http_status(403)
        expect(post :create, params: batch_params).to have_http_status(403)
        # expect(get :index, format: 'json').to have_http_status(403)
        # expect(get :show, id: batch.id, format: 'json').to have_http_status(403)
        # expect(get :new, format: 'json').to have_http_status(403)
        # expect(post :create, format: 'json').to have_http_status(403)
      end
    end

    describe "as an admin user" do
      let(:current_user) { FactoryBot.create(:admin) }
      it "all routes should return 200" do
        expect(get :index).to have_http_status(200)
        expect(get :show, id: batch.id).to have_http_status(200)
        expect(get :new).to have_http_status(200)
        expect(post :create, params: batch_params).to have_http_status(200)
        # expect(get :index, format: 'json').to have_http_status(200)
        # expect(get :show, id: batch.id, format: 'json').to have_http_status(200)
        # expect(get :new, format: 'json').to have_http_status(200)
        # expect(post :create, format: 'json').to have_http_status(200)
      end
    end
  end
end
