# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::BatchIngest::BatchesController, type: :routing do
  routes { Hyrax::BatchIngest::Engine.routes }

  it 'routes to the list of all Batches' do
    expect(get: batches_path).to route_to(
      controller: 'hyrax/batch_ingest/batches',
      action: 'index'
    )
  end

  it 'routes to Batch details page' do
    expect(get: batch_path(123)).to route_to(
      controller: 'hyrax/batch_ingest/batches',
      action: 'show',
      id: '123'
    )
  end
end
