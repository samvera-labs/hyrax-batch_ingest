# frozen_string_literal: true
require 'rails_helper'
require 'rspec/collection_matchers'

RSpec.describe Hyrax::BatchIngest::BatchItem do
  describe 'validate' do
    before { batch_item.validate }
    context 'with an invalid status' do
      let(:batch_item) { build(:batch_item, status: "not a valid status") }
      it 'adds an error for invalid status' do
        expect(batch_item).to have(1).error_on(:status)
      end
    end
  end
end
