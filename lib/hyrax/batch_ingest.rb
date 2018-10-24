# frozen_string_literal: true
require "hyrax/batch_ingest/engine"
require 'hyrax'

module Hyrax
  module BatchIngest
    # Your code goes here...
    class << self
      def root
        Pathname.new File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))
      end
    end
  end
end
