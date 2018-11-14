# frozen_string_literal: true
module Hyrax
  module BatchIngest
    class AvalonBatchItemIngester < Hyrax::BatchIngest::BatchItemIngester
      def ingest
        work = AudiovisualWork.new
        ability = Ability.new(User.find(email: @batch_item.submitter_email))
        env = Hyrax::Actors::Environment.new(work, ability, attributes)
        Hyrax::CurationConcern.actor.create(env)
        return work if work.persisted?
        raise Hyrax::BatchIngest::IngesterError.new("Work failed persisting: #{work.errors.full_messages.join(' ')}")
      end

      private

        def attributes
          source_data = JSON.parse(@batch_item.source_data)
          fields = source_data[fields]
          # Remove fields not present on the model
          attrs = fields.slice(*AudiovisualWork.properties)
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
