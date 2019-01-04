# frozen_string_literal: true
require 'rails_helper'

describe 'hyrax/dashboard/sidebar/_repository_content.html.erb', type: :view do
  let(:user) { create(:user) }
  let(:menu) { Hyrax::MenuPresenter.new(view) }
  let(:can_view_batches) { nil }

  before do
    allow(view).to receive(:signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:can?).with(:index, Hyrax::BatchIngest::Batch).and_return(can_view_batches)
  end

  context 'as any logged in user' do
    before { render 'hyrax/dashboard/sidebar/repository_content', menu: menu }
    subject { rendered }

    it 'has the Collection link' do
      is_expected.to have_link t('hyrax.admin.sidebar.collections')
    end

    it 'has the Work link' do
      is_expected.to have_link t('hyrax.admin.sidebar.works')
    end
  end

  context 'as a user who can view Batch info' do
    before { render 'hyrax/dashboard/sidebar/repository_content', menu: menu }
    subject { rendered }
    let(:can_view_batches) { true }
    it 'has the Batches link' do
      is_expected.to have_link 'Batches'
    end
  end

  context 'as a user who cannot view Batch info' do
    before { render 'hyrax/dashboard/sidebar/repository_content', menu: menu }
    subject { rendered }
    let(:can_view_batches) { false }
    it 'does not have the Batches link' do
      is_expected.not_to have_link 'Batches'
    end
  end
end
