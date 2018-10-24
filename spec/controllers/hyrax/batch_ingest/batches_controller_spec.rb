# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::BatchIngest::BatchesController, type: :controller do
  routes { Hyrax::BatchIngest::Engine.routes }
  let(:admin_user) { create :admin }

  context 'when there are no ingest types configured' do
    before do
      # Login as an admin user
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
end
