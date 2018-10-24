require 'yaml'
require 'hyrax/batch_ingest/error'

module Hyrax
  module BatchIngest
    class Config
      attr_reader :config_file_path, :ingest_type

      def initialize(ingest_type:, config_file_path: nil)
        @config_file_path = config_file_path || default_config_file_path
        @ingest_type = ingest_type
        config
      end

      def reader
        # TODO: Raise custom error on invalid Reader
        @config['reader']
      end

      def source_validator
        # TODO: Raise custom error on invalid SourceValidator
        @config['source_validator']
      end

      def mapper
        # TODO: Raise custom error on invalid Mapper
        @config['mapper']
      end

      private

        def config
          @config ||= parsed_yaml['ingest_types'][ingest_type]
        end

        def raw_config
          File.read config_file_path
        rescue Errno::ENOENT => e
          raise Hyrax::BatchIngest::Error::MissingConfig
        end

        def parsed_yaml
          @parsed_yaml ||= YAML.load(raw_config)
        end

        def default_config_file_path
          Rails.root.join('config', 'batch_ingest.yml')
        end
    end
  end
end
