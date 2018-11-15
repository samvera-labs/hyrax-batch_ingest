# frozen_string_literal: true
require 'rails_helper'

describe Hyrax::BatchIngest::BatchReader do
  subject { described_class.new('foo') }
  describe 'public interface' do
    it { is_expected.to respond_to :read }
    it { is_expected.to respond_to :has_been_read? }
    it { is_expected.to respond_to :batch_items }
    it { is_expected.to respond_to :submitter_email }
    it { is_expected.to respond_to :error }
    it { is_expected.to respond_to :source_location }
  end
end
