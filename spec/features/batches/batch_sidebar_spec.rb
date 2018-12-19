# frozen_string_literal: true
require 'rails_helper'

describe 'Batch Sidebar', type: :feature do
  before do
    login_as user
    visit '/'
  end

  context 'as a user who can view Batch info' do
    let(:user) { create(:admin) }

    it 'has the Batches link' do
      expect(page).to have_link 'Batches'
    end
  end

  context 'as a user who cannot view Batch info' do
    let(:user) { create(:user) }

    it 'does not have the Batches link' do
      expect(page).not_to have_link 'Batches'
    end
  end
end
