# frozen_string_literal: true

# Load a default example configuration for Hyrax::BatchIngest before each
# context, providing the classes specified in the configuration.
# To load a different batch ingest config file call
# Hyrax::BatchIngest.config.load_config().
RSpec.configure do |config|
  config.before(:context) do
    Hyrax::BatchIngest.config.load_config(File.join(fixture_path, 'example_config.yml'))
    class ExampleReader < Hyrax::BatchIngest::BatchReader; end
  end
end
