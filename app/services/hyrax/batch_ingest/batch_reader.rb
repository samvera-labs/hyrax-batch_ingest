# frozen_string_literal: true

class Hyrax::BatchIngest::BatchReader
  attr_reader :error, :source_location, :submitter_email, :batch_items,
              :admin_set_id

  def initialize(source_location)
    @source_location = source_location
    @submitter_email = nil
    @batch_items = []
    @error = nil
    @admin_set_id = nil
  end

  def read; end

  def been_read?
    @batch_items.present?
  end
end
