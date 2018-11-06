# frozen_string_literal: true

require 'yaml'
require 'hyrax/batch_ingest/errors'
require 'hyrax/batch_ingest/ingest_type_config'

module Hyrax
  module BatchIngest
    class Config
      attr_reader :config_file_path, :ingest_types

      def initialize(config_file_path = nil)
        @config_file_path = config_file_path || default_config_file_path
        @ingest_types = {}
        # Only attempt to load if a config file path was passed in OR if the
        # default config file exists. Otherwise, don't load anything.
        load_config(config_file_path) if config_file_path || File.exist?(default_config_file_path)
      end

      # Loads configuration from the specified config file.
      def load_config(config_file_path)
        @config_file_path = config_file_path || default_config_file_path
        @ingest_types = {}
        parsed_yaml['ingest_types'].each do |ingest_type, options|
          add_ingest_type_config(ingest_type, options)
        end
      end

      def add_ingest_type_config(ingest_type, opts = {})
        @ingest_types[ingest_type.to_sym] = Hyrax::BatchIngest::IngestTypeConfig.new(ingest_type, opts)
      end

      def ingest_type(ingest_type)
        raise Hyrax::BatchIngest::UnrecognizedIngestTypeError.new(ingest_type) unless ingest_types.key? ingest_type
        ingest_types[ingest_type]
      end

      def default_config_file_path
        Rails.root.join('config', 'batch_ingest.yml')
      end

      private

        def parsed_yaml
          @parsed_yaml ||= YAML.safe_load(raw_config)
        end

        def raw_config
          File.read config_file_path
        rescue Errno::ENOENT
          raise Hyrax::BatchIngest::ConfigFileNotFoundError.new(config_file_path)
        end
    end
  end
end
