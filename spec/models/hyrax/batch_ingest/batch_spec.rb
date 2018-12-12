# frozen_string_literal: true
require 'rails_helper'
require 'rspec/collection_matchers'

RSpec.describe Hyrax::BatchIngest::Batch do
  describe '#validate' do
    before { batch.validate }
    context 'with an invalid status' do
      let(:batch) { build(:batch, status: "not a valid status") }
      it 'adds an error for the invalid status' do
        expect(batch).to have(1).error_on(:status)
      end
    end
  end

  describe '#admin_set' do
    context 'when the Batch record does NOT have an admin_set_id' do
      let(:batch) { build(:batch, admin_set_id: nil) }
      it 'returns nil' do
        expect(batch.admin_set).to eq nil
      end
    end

    context 'when Batch record has an admin_set_id' do
      let(:admin_set) { build(:admin_set, id: 'admin_set/example') }
      let(:batch) { build(:batch, admin_set_id: admin_set.id) }

      before do
        # Mock the existence of an AdminSet in Fedora since we're not actually
        # persisting one to Fedora in order to save time.
        allow(AdminSet).to receive(:find).with(admin_set.id).and_return(admin_set)
      end

      it 'returns the AdminSet instance' do
        expect(batch.admin_set).to eq admin_set
      end
    end

    context 'when Batch record has an invalid admin_set_id' do
      let(:batch) { build(:batch, admin_set_id: 'gobbledygook') }
      it 'raises ActiveFedora::ObjectNotFoundError' do
        expect { batch.admin_set }.to raise_error ActiveFedora::ObjectNotFoundError
      end
    end
  end

  describe '#submitter' do
    context 'when there is a User record that has email equal to #submitter_email' do
      let(:user) { create(:user, email: "user1@example.org") }
      let(:batch) { build(:batch, submitter_email: user.email) }
      it 'returns the User instance' do
        expect(batch.submitter).to eq user
      end
    end

    context 'when there is NOT a User record that has email equal to #submitter_email' do
      let(:batch) { build(:batch, submitter_email: "user_does_not_exist@example.com") }
      it 'raises an ActiveRecord::RecordNotFound' do
        expect { batch.submitter }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context 'when #submitter_email is nil' do
      let(:batch) { build(:batch, submitter_email: nil) }
      it 'returns nil' do
        expect(batch.submitter).to be_nil
      end
    end
  end
end
