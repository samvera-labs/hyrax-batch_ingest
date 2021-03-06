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
        manifests = unprocessed_manifests
        Rails.logger.info "<< Found #{manifests.count} unprocessed manifests for admin_set #{@admin_set.title.first} >>" if manifests.count.positive?
        manifests.each do |manifest|
          Rails.logger.info "<< Processing manifest #{manifest} for admin set #{admin_set.id} >>"
          # submitter_email will be populated later by batch reader
          Hyrax::BatchIngest::BatchRunner.new(ingest_type: 'Avalon Ingest Type', source_location: manifest, admin_set_id: admin_set.id).run
        end
      end

      protected

        # Returns all unprocessed manifests for this admin set.
        def unprocessed_manifests
          raise Hyrax::BatchIngest::ScannerError.new("Cannot use abstract BatchScanner class.")
        end
    end
  end
end
