# frozen_string_literal: true
module Hyrax
  module BatchIngest
    class Engine < ::Rails::Engine
      isolate_namespace Hyrax::BatchIngest

      # Add engine's assets to Rails app's precompile list.
      initializer "hyrax-batch_ingest.assets.precompile" do |app|
        app.config.assets.precompile += %w[hyrax/batch_ingest/batch_ingest.scss]
      end
    end
  end
end
