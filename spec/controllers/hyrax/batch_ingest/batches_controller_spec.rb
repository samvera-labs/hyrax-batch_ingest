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

  describe 'authorization', clean_repo: true do
    let(:admin_set) { create(:admin_set, id: 'this', with_permission_template: true) }
    let(:admin_set_other) { create(:admin_set, id: 'other', with_permission_template: true) }
    let(:batch_items) { build_list(:batch_item, 1) }
    let(:batch_params) do
      { batch: { ingest_type: 'example_ingest_type', admin_set_id: admin_set.id, submitter_email: current_user.email, batch_source: fixture_file_upload('example_batches/empty.zip') } }
    end
    let(:batch) { create(:batch, admin_set_id: admin_set.id, submitter_email: current_user.email, batch_items: batch_items) }
    let(:batch_other_created) { create(:batch, admin_set_id: admin_set.id, submitter_email: 'other@example.com') }
    let(:batch_other_managed) { create(:batch, admin_set_id: admin_set_other.id) }

    before { sign_in current_user }

    context "as an admin user" do
      let(:current_user) { admin_user }

      it "#index should return 200" do
        expect(get(:index)).to have_http_status(200)
      end

      it "#show any batch should return 200" do
        expect(get(:show, params: { id: batch_other_managed.id })).to have_http_status(200)
      end

      it "#new routes should return 200" do
        expect(get(:new)).to have_http_status(200)
      end

      it "#post routes should return 302" do
        expect(post(:create, params: batch_params)).to have_http_status(302)
      end
    end

    context "as an admin set manager" do
      let(:current_user) { user }

      before do
        create(:permission_template_access,
               :manage,
               permission_template: admin_set.permission_template,
               agent_type: 'user',
               agent_id: current_user.user_key)
        admin_set.reset_access_controls!
      end

      it "#index should return 200" do
        expect(get(:index)).to have_http_status(200)
      end

      it "#show batch created by others for a managed admin set managed by user should return 200" do
        expect(get(:show, params: { id: batch_other_created.id })).to have_http_status(200)
      end

      it "#show batch created by others for an admin set not managed by user should return 401" do
        expect(get(:show, params: { id: batch_other_managed.id })).to have_http_status(401)
      end

      it "#new routes should return 200" do
        expect(get(:new)).to have_http_status(200)
      end

      it "#post routes should return 302" do
        expect(post(:create, params: batch_params)).to have_http_status(302)
      end
    end

    context "as an admin set depositor" do
      let(:current_user) { FactoryBot.create(:user) }

      before do
        create(:permission_template_access,
               :deposit,
               permission_template: admin_set.permission_template,
               agent_type: 'user',
               agent_id: current_user.user_key)
        admin_set.reset_access_controls!
      end

      it "#index should return 200" do
        expect(get(:index)).to have_http_status(200)
      end

      it "#show batch created by user should return 200" do
        expect(get(:show, params: { id: batch.id })).to have_http_status(200)
      end

      it "#show batch created by others should return 401" do
        expect(get(:show, params: { id: batch_other_created.id })).to have_http_status(401)
      end

      it "#new routes should return 200" do
        expect(get(:new)).to have_http_status(200)
      end

      it "#post routes should return 302" do
        expect(post(:create, params: batch_params)).to have_http_status(302)
      end
    end

    context "as a unauthorized batch user" do
      let(:current_user) { FactoryBot.create(:user) }

      it "#index should return 401" do
        # TODO: index request gets 302 instead of 401, due to a hyrax bug (see https://github.com/samvera/hyrax/issues/3444)
        # following test expects 302 as a work-around; once the bug is fixed, we can switch back to 401.
        # expect(get(:index)).to have_http_status(401)
        expect(get(:index)).to have_http_status(302)
      end

      it "#show should return 401" do
        expect(get(:show, params: { id: batch.id })).to have_http_status(401)
      end

      it "#new should return 401" do
        # TODO: new request gets 302 instead of 401, due to a hyrax bug (see https://github.com/samvera/hyrax/issues/3444)
        # following test expects 302 as a work-around; once the bug is fixed, we can switch back to 401.
        # expect(get(:new)).to have_http_status(401)
        expect(get(:new)).to have_http_status(302)
      end

      it "#post should return 401" do
        expect(post(:create, params: batch_params)).to have_http_status(401)
      end
    end
  end
end
