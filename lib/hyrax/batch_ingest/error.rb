# frozen_string_literal: true

module Hyrax
  module BatchIngest
    module Error
      class MissingConfig < StandardError; end
      class InvalidConfig < StandardError; end
    end
  end
end
