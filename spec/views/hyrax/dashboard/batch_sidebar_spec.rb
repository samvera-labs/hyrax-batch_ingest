# frozen_string_literal: true
require 'rails_helper'

# describe 'hyrax/dashboard/sidebar/_activity.html.erb', type: :view do
describe 'hyrax/dashboard/_sidebar.html.erb', type: :view do
  # let(:user) { stub_model(User, user_key: 'mjg', name: 'Foobar') }
  let(:user) { create(:user) }

  before do
    allow(view).to receive(:signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(user)
    # assign(:user, user)
    allow(view).to receive(:can?).with(:index, Hyrax::BatchIngest::Batch).and_return(:can_view_batches)
  end

  context 'as a user who can view Batch info' do
    let(:can_view_batches) { true }

    before { render }
    subject { rendered }

    it 'has the Batches link' do
      is_expected.to have_link 'Batches'
    end
  end

  context 'as a user who cannot view Batch info' do
    let(:can_view_batches) { false }

    before { render }
    subject { rendered }

    it 'does not have the Batches link' do
      is_expected.not_to have_link 'Batches'
    end
  end

  # before do
  #   login_as user
  #   visit '/'
  # end
  #
  # context 'as a user who can view Batch info' do
  #   let(:user) { create(:admin) }
  #
  #   it 'has the Batches link' do
  #     expect(page).to have_link 'Batches'
  #   end
  # end
  #
  # context 'as a user who cannot view Batch info' do
  #   let(:user) { create(:user) }
  #
  #   it 'does not have the Batches link' do
  #     expect(page).not_to have_link 'Batches'
  #   end
  # end
end
