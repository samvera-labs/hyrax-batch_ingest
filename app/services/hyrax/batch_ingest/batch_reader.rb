# frozen_string_literal: true

module Hyrax
  module BatchIngest
    class BatchReader
      attr_reader :source_location, :options

      def initialize(source_location, opts = {})
        @source_location = source_location
        @read = false
        @submitter_email = nil
        @batch_items = nil
        @admin_set_id = nil
        @options = opts || {}
      end

      def submitter_email
        read unless been_read?
        @submitter_email
      end

      def batch_items
        read unless been_read?
        @batch_items
      end

      def admin_set_id
        read unless been_read?
        @admin_set_id
      end

      def read
        perform_read
      ensure
        @read = true
      end

      def been_read?
        @read
      end

      # Deletes the manifest of this batch from its source location.
      def delete_manifest
        raise Hyrax::BatchIngest::ReaderError.new("Cannot use abstract BatchReader class.")
      end

      protected

        def perform_read
          raise Hyrax::BatchIngest::ReaderError.new("Cannot use abstract BatchReader class.")
        end
    end
  end
end
