# frozen_string_literal: true
require 'rails_helper'

# describe 'hyrax/dashboard/_sidebar.html.erb', type: :view do
# describe 'hyrax/dashboard/sidebar/_activity.html.erb', type: :view do
describe 'hyrax/dashboard/sidebar/_repository_content.html.erb', type: :view do
  # let(:user) { stub_model(User, user_key: 'mjg', name: 'Foobar') }
  let(:user) { create(:user) }
  let(:menu) { Hyrax::MenuPresenter.new(view) }

  before do
    allow(view).to receive(:signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(user)
    # assign(:user, user)
    allow(view).to receive(:can?).with(:index, Hyrax::BatchIngest::Batch).and_return(:can_view_batches)
    allow(view).to receive(:can?).with(:read, :admin_dashboard).and_return(true)
    # allow(view).to receive(:can?).with(:manage_any, AdminSet).and_return(true)
    # allow(view).to receive(:can?).with(:review, :submissions).and_return(true)
    # allow(view).to receive(:can?).with(:manage, User).and_return(true)
    # allow(view).to receive(:can?).with(:update, :appearance).and_return(true)
    # allow(view).to receive(:can?).with(:manage, Hyrax::Feature).and_return(true)
    # allow(view).to receive(:can?).with(:manage, Sipity::WorkflowResponsibility).and_return(true)
    # allow(view).to receive(:can?).with(:manage, :collection_types).and_return(true)
    # render 'hyrax/dashboard/sidebar/repository_content', menu: menu
    # subject { rendered }
  end

  # it 'has the Collection link' do
  #   is_expected.to have_link t('hyrax.admin.sidebar.collections')
  # end
  #
  # it 'has the Work link' do
  #   is_expected.to have_link t('hyrax.admin.sidebar.works')
  # end

  context 'as a user who can view Batch info' do
    let(:can_view_batches) { true }

    # before { render 'hyrax/dashboard/sidebar/activity', menu: menu }
    before { render 'hyrax/dashboard/sidebar/repository_content', menu: menu }
    subject { rendered }

    it 'has the Batches link' do
      is_expected.to have_link 'Batches'
    end

    it 'has the Collection link' do
      is_expected.to have_link t('hyrax.admin.sidebar.collections')
    end

    it 'has the Work link' do
      is_expected.to have_link t('hyrax.admin.sidebar.works')
    end

  end

  context 'as a user who cannot view Batch info' do
    let(:can_view_batches) { false }

    before { render 'hyrax/dashboard/sidebar/repository_content', menu: menu}
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
