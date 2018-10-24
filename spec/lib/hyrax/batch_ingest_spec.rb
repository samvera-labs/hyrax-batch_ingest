# frozen_string_literal: true
require 'rails_helper'

describe Hyrax::BatchIngest do
  describe '::VERSION' do
    let(:semver_pattern) { /\d+\.\d+\.\d/ }
    it 'returns a Semantic Version number' do
      expect(Hyrax::BatchIngest::VERSION).to match semver_pattern
    end
  end

  describe '.config' do
    it 'returns an instance of Hyrax::BatchIngest::Config' do
      expect(described_class.config).to be_a Hyrax::BatchIngest::Config
    end
  end

  describe '.configure' do
    it 'takes a block and passes the Hyrax::BatchIngest::Config instance to it' do
      described_class.configure do |config|
        expect(config).to be_a Hyrax::BatchIngest::Config
      end
    end
  end
end
