# frozen_string_literal: true
module Hyrax
  module BatchIngest
    class GenericWorkBatchItemIngester < BatchItemIngester
      def ingest
        work = GenericWork.new
        ability = Ability.new(User.find(email: @batch_item.submitter_email))
        env = Hyrax::Actors::Environment.new(work, ability, attributes)
        Hyrax::CurationConcern.actor.create(env)
        return work if work.persisted?
        raise Hyrax::BatchIngest::IngesterError.new("Work failed persisting: #{work.errors.full_messages.join(' ')}")
      end

      private

        def attributes
          { title: ['Title'], creator: ['Creator'], keyword: ['Keyword'], rights: '' }
        end
    end
  end
end
