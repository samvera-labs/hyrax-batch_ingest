require 'rails_helper'

RSpec.describe Hyrax::BatchIngest::BatchItemsController, :type => :routing do
  routes { Hyrax::BatchIngest::Engine.routes }

  it 'routes to Batch details page' do
    expect(get: batch_item_path(id: 456, batch_id: 123)).to route_to(
      controller: 'hyrax/batch_ingest/batch_items',
      action: 'show',
      id: '456',
      batch_id: '123'
    )
  end
end
