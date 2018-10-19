require 'rails_helper'

describe 'List Batches', type: :feature do
  context 'as a Batch Ingest Admin User' do
    let(:admin) { create(:admin) }
    before { login_as admin }

    describe 'default view' do
      before { visit '/batches' }
      it 'has the header "Batches"' do
        # TODO: more specialized matcher for page header?
        expect(page).to have_header 'Batches'
      end
    end
  end
end
