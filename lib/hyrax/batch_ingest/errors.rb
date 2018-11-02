# frozen_string_literal: true

module Hyrax
  module BatchIngest
    class BatchIngestError < ::StandardError; end
    class MissingConfig < BatchIngestError; end
    class InvalidConfig < BatchIngestError; end
    class ReaderError < BatchIngestError; end
  end
end
