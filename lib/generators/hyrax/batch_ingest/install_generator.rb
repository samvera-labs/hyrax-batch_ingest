# frozen_string_literal: true
module Hyrax
  module BatchIngest
    class InstallGenerator < Rails::Generators::Base
      desc <<-EOS
        This generator makes the following changes to your application:
         1. Adds BatchIngest routes to your ./config/routes.rb
      EOS

      def add_routes
        route "mount Hyrax::BatchIngest::Engine, at: '/'"
      end
    end
  end
end
