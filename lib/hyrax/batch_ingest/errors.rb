# frozen_string_literal: true

module Hyrax
  module BatchIngest
    class BatchIngestError < ::StandardError; end
    class ReaderError < BatchIngestError; end

    class ConfigFileNotFoundError < BatchIngestError
      def initialize(path)
        super("Batch ingest config file not found: '#{path}'")
      end
    end

    class InvalidConfigOptionsError < BatchIngestError
      def initialize(invalid_options)
        super("Invalid batch ingest configuration option(s): '#{Array(invalid_options).join("', '")}'")
      end
    end

    class MissingRequiredConfigOptionsError < BatchIngestError
      def initialize(required_config_options)
        super("Mising requied configuration option(s): '#{Array(required_config_options).join("', '")}'")
      end
    end

    class ReaderClassNotFoundError < BatchIngestError
      def initialize(const_name)
        super("Batch ingest reader class '#{const_name}' was not found")
      end
    end

    class MapperClassNotFoundError < BatchIngestError
      def initialize(const_name)
        super("Batch ingest mapper class '#{const_name}' was not found")
      end
    end

    class UnrecognizedIngestTypeError < BatchIngestError
      def initialize(unrecognized_ingest_type)
        super("Unrecognized batch ingest type: '#{unrecognized_ingest_type}'")
      end
    end
  end
end
