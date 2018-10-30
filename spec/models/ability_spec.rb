# frozen_string_literal: true
require 'cancan/matchers'

describe Ability, type: :model do
  subject(:ability) { described_class.new(current_user) }
  let(:batch) { FactoryBot.create(:batch) }

  describe "as a user" do
    let(:current_user) { FactoryBot.create(:user) }
    it {
      is_expected.not_to be_able_to(:create, batch)
      is_expected.not_to be_able_to(:show, batch)
      is_expected.not_to be_able_to(:edit, batch)
      is_expected.not_to be_able_to(:update, batch)
      is_expected.not_to be_able_to(:destroy, batch)
    }
  end

  describe "as an admin" do
    let(:current_user) { FactoryBot.create(:admin) }
    it {
      is_expected.to be_able_to(:create, batch)
      is_expected.to be_able_to(:show, batch)
      is_expected.to be_able_to(:edit, batch)
      is_expected.to be_able_to(:update, batch)
      is_expected.to be_able_to(:destroy, batch)
    }
  end
end
