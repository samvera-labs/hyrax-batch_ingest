# frozen_string_literal: true
require 'hyrax/batch_ingest/errors'
require "active_support/core_ext/hash/indifferent_access"

module Hyrax
  module BatchIngest
    class IngestTypeConfig
      attr_reader :ingest_type, :options

      def initialize(ingest_type, opts = {})
        @ingest_type = ingest_type.to_sym
        @options = validate_options(opts)
      end

      def reader
        @reader ||= Object.const_get(options[:reader])
      rescue NameError
        raise Hyrax::BatchIngest::ReaderClassNotFoundError.new(options[:reader])
      end

      def ingester
        @ingester ||= Object.const_get(options[:ingester])
      rescue NameError
        raise Hyrax::BatchIngest::IngesterClassNotFoundError.new(options[:ingester])
      end

      def label
        options[:label]
      end

      private

        def validate_options(options = {})
          # Convert to hash with indifferent access to make accessing options
          # less error-prone throughout.
          options = options.with_indifferent_access
          option_keys = options.keys.map(&:to_sym)
          invalid_options = option_keys - valid_options
          raise Hyrax::BatchIngest::InvalidConfigOptionsError.new(invalid_options) unless invalid_options.empty?
          missing_required_options = required_options - option_keys
          raise Hyrax::BatchIngest::MissingRequiredConfigOptionsError.new(missing_required_options) unless missing_required_options.empty?
          options
        end

        # Returns an array of symbols representing valid options.
        def valid_options
          [:reader, :ingester, :label]
        end

        # Returns an array of symbols representing required options.
        def required_options
          valid_options - [:label]
        end
    end
  end
end
