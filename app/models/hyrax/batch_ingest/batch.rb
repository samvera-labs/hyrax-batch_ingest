module Hyrax::BatchIngest
  class Batch < ApplicationRecord
    has_many :batch_items
  end
end
