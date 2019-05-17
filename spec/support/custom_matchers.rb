# frozen_string_literal: true
module CustomMatchers
  def have_header(text)
    have_css 'h1', text: text
  end

  # Returns a matcher for whether the given batch_item is in the batch's list of
  # items. The select used is a data attribute containing the BatchItem ID.
  def have_batch_item_row(batch_item)
    raise_argument_error_if_not_batch_items batch_item
    have_css("tr[data-batch-item-id=\"#{batch_item.id}\"]")
  end

  # Returns a matcher for whether all the given batch_items are in the search
  # results.
  def have_batch_item_rows(batch_items = [])
    raise_argument_error_if_not_batch_items batch_items
    batch_items = batch_items.to_a.dup
    batch_items.reduce have_batch_item_row(batch_items.shift) do |memo, batch_item|
      memo.and(have_batch_item_row(batch_item))
    end
  end

  # Returns a matcher for whether the given batch_items are the ONLY records in
  # the search results.
  def only_have_batch_item_rows(batch_items = [])
    raise_argument_error_if_not_batch_items batch_items
    # Has all of the batch_items in the search results...
    have_batch_item_rows(batch_items).and(
      # ... and only has batch_items.count search results.
      have_css("tr[data-batch-item-id]", count: batch_items.count)
    )
  end

  def raise_argument_error_if_not_batch_items(batch_items = [])
    batch_items = batch_items.to_a if batch_items.respond_to?(:to_a)
    batch_items = Array(batch_items)

    all_are_batch_items = batch_items.all? { |item| item.is_a? Hyrax::BatchIngest::BatchItem }
    raise ArgumentError, "#{caller[0]} expects instance(s) of BatchItem, but '#{batch_items.map(&:class).join(', ')}' was given" unless all_are_batch_items
  end
end

RSpec.configure { |c| c.include CustomMatchers }
