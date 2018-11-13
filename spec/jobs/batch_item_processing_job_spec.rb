# frozen_string_literal: true
require 'rails_helper'

describe Hyrax::BatchIngest::BatchItemProcessingJob do
  let(:batch_item) { FactoryBot.create(:enqueued_batch) }
  describe '#perform' do

  end
end
