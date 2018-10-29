# frozen_string_literal: true
module Hyrax
  module BatchIngest
    class InstallGenerator < Rails::Generators::Base
      desc <<-EOS
        This generator makes the following changes to your application:
         1. Adds BatchIngest routes to your ./config/routes.rb
         2. Installs and runs db migrations
         3. Adds batch_ingest-specific abilities
      EOS

      def add_routes
        route "mount Hyrax::BatchIngest::Engine, at: '/'"
      end

      def install_migrations
        rake 'hyrax_batch_ingest:install:migrations'
      end

      def insert_abilities
        insert_into_file 'app/models/ability.rb', after: /Hyrax::Ability/ do
          "\n  include Hyrax::BatchIngest::Ability\n"
        end
      end
    end
  end
end
