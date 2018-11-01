class BatchReader
  def initialize(source_location)
    @source_location = source_location
    @read = false
    @name = nil
    @submitter_email = nil
    @batch_items = nil
  end

  # TODO refer to Issue #58 to decide if we will add/populate this field
  def name
    read unless @read
    @name
  end

  def submitter_email
    read unless @read
    @submitter_email
  end

  def batch_items
    read unless @read
    @batch_items
  end

  protected

  def read()
  end
end