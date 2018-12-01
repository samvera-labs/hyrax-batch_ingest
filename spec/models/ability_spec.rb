# frozen_string_literal: true
require 'cancan/matchers'

describe Ability, type: :model do
  subject(:ability) { described_class.new(current_user) }
  let(:current_user) { FactoryBot.create(:user) }
  let(:admin_set_id) { 'as' }
  let(:batch) { FactoryBot.create(:batch, admin_set_id: admin_set_id, submitter_email: current_user.email) }
  let(:batch_other_created) { FactoryBot.create(:batch, admin_set_id: admin_set_id, submitter_email: 'other@example.com') }
  let(:batch_other_managed) { FactoryBot.create(:batch, admin_set_id: 'other') }

  context ': an admin' do
    let(:current_user) { FactoryBot.create(:admin) }
    it 'is allowed to perform all actions on all batches' do
      is_expected.to be_able_to(:new, Hyrax::BatchIngest::Batch)
      is_expected.to be_able_to(:create, batch)
      is_expected.to be_able_to(:index, Hyrax::BatchIngest::Batch)
      is_expected.to be_able_to(:show, batch_other_managed)
      is_expected.to be_able_to(:read, batch_other_managed)
      is_expected.to be_able_to(:destroy, batch_other_managed)
    end
  end

  context ': an admin set manager' do
    let(:admin_set_id) { 'as_mu' }
    let!(:admin_set) { create(:admin_set, id: admin_set_id, with_permission_template: true) }
    let!(:admin_set_other) { create(:admin_set, id: batch_other_managed.admin_set_id, with_permission_template: true) }

    before do
      create(:permission_template_access,
             :manage,
             permission_template: admin_set.permission_template,
             agent_type: 'user',
             agent_id: current_user.user_key)
      admin_set.reset_access_controls!
    end

    it 'is allowed to initiate a new batch ' do
      is_expected.to be_able_to(:new, Hyrax::BatchIngest::Batch)
    end

    it 'is allowed to create a batch for an admin set managed by him' do
      is_expected.to be_able_to(:create, batch)
    end

    it 'is allowed to display the batch index' do
      is_expected.to be_able_to(:index, Hyrax::BatchIngest::Batch)
    end

    it 'is allowed to read/cancel a batch created by others for an admin set managed by him' do
      is_expected.to be_able_to(:show, batch_other_created)
      is_expected.to be_able_to(:read, batch_other_created)
      is_expected.to be_able_to(:destroy, batch_other_created)
    end

    it 'is not allowed to read/cancel a batch created for an admin set not managed by him' do
      is_expected.not_to be_able_to(:show, batch_other_managed)
      is_expected.not_to be_able_to(:read, batch_other_managed)
      is_expected.not_to be_able_to(:destroy, batch_other_managed)
    end
  end

  context ': an admin set depositor' do
    let(:admin_set_id) { 'as_du' }
    let!(:admin_set) { create(:admin_set, id: admin_set_id, with_permission_template: true) }
    let!(:admin_set_other) { create(:admin_set, id: batch_other_managed.admin_set_id, with_permission_template: true) }

    before do
      create(:permission_template_access,
             :deposit,
             permission_template: admin_set.permission_template,
             agent_type: 'user',
             agent_id: current_user.user_key)
      admin_set.reset_access_controls!
    end

    it 'is allowed to initiate a new batch ' do
      is_expected.to be_able_to(:new, Hyrax::BatchIngest::Batch)
    end

    it 'is allowed to create a batch for an admin set accessible to him' do
      is_expected.to be_able_to(:create, batch)
    end

    it 'is not allowed to create a batch for an admin set inaccessible to him' do
      is_expected.not_to be_able_to(:create, batch_other_managed)
    end

    it 'is allowed to display the batch index' do
      is_expected.to be_able_to(:index, Hyrax::BatchIngest::Batch)
    end

    it 'is allowed to read/cancel a batch created by him' do
      is_expected.to be_able_to(:show, batch)
      is_expected.to be_able_to(:read, batch)
      is_expected.to be_able_to(:destroy, batch)
    end

    it 'is not allowed to read/cancel a batch created by others even within the same admin set' do
      is_expected.not_to be_able_to(:show, batch_other_created)
      is_expected.not_to be_able_to(:read, batch_other_created)
      is_expected.not_to be_able_to(:destroy, batch_other_created)
    end
  end

  context ': an unauthorized batch user' do
    let!(:admin_set) { create(:admin_set, id: admin_set_id, with_permission_template: true) }

    it 'is not allowed to perform any action on any batch' do
      is_expected.not_to be_able_to(:new, Hyrax::BatchIngest::Batch)
      is_expected.not_to be_able_to(:create, batch)
      is_expected.not_to be_able_to(:index, Hyrax::BatchIngest::Batch)
      is_expected.not_to be_able_to(:show, batch)
      is_expected.not_to be_able_to(:read, batch)
      is_expected.not_to be_able_to(:destroy, batch)
    end
  end
end
