# frozen_string_literal: true
module Hyrax
  module BatchIngest
    class AvalonBatchMapper < Hyrax::BatchIngest::BatchMapper
      def map
        source_data = JSON.parse(@batch_item.source_data)
        fields = source_data[fields]
        # Remove fields not present on the model
        attrs = fields.slice(*@config.work_class.properties)
        # Make singular fields have singular values
        ['date_issued', 'physical_description', 'bibliographic_id', 'table_of_contents'].each do |field|
          attrs[field] = attrs[field].first if attrs[field].present?
        end
        # TODO: Handle related_item and note
        # TODO: Add file metadata
        attrs
      end
    end
  end
end
