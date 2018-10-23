# frozen_string_literal: true
require 'rails_helper'

describe Hyrax::BatchIngest do
  describe '::VERSION' do
    let(:semver_pattern) { /\d+\.\d+\.\d/ }
    it 'returns a Semantic Version number' do
      expect(Hyrax::BatchIngest::VERSION).to match semver_pattern
    end
  end
end
