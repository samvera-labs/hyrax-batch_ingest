# frozen_string_literal: true
require "hyrax/batch_ingest/version"
require "hyrax/batch_ingest/engine"
require 'hyrax/batch_ingest/config'
require 'hyrax'

module Hyrax
  module BatchIngest
    # Your code goes here...
    class << self
      def root
        Pathname.new File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))
      end

      def config
        @config ||= Hyrax::BatchIngest::Config.new
      end

      def configure
        yield(config) if block_given?
      end
    end
  end
end
