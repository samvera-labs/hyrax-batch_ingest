# frozen_string_literal: true

module Hyrax::BatchIngest
  class BatchItem < ApplicationRecord
    belongs_to :batch
  end
end
