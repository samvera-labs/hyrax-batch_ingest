# frozen_string_literal: true
module Hyrax
  module BatchIngest
    class BatchScanner
      attr_reader :admin_set

      def initialize(admin_set)
        @admin_set = admin_set
      end

      # Scans for all unprocessed manifests for this admin set and creates/run batches for them.
      def scan
        manifests = new_manifests
        logger.info "<< Found #{manifests.count} new manifests for admin_set #{@admin_set.title.first} >>" if manifests.count > 0
        manifests.each do |manifest|
          logger.info "<< Processing manifest #{manifest.absolute_path} for admin set #{admin_set.id} >>"
          # submitter_email will be populated later by batch reader
          Hyrax::BatchIngest::BatchRunner.new(ingest_type: 'Avalon Ingest Type', source_location: manifest.absolute_path, admin_set_id: admin_set.id).run
        end
      end

      protected

      # Returns all unprocessed manifests for this admin set.
      def new_manifests
        raise Hyrax::BatchIngest::ScannerError.new("Cannot use abstract BatchScanner class.")
      end
    end
  end
end