module Hyrax::BatchIngest
  class BatchItem < ApplicationRecord
    belongs_to :batch
  end
end
