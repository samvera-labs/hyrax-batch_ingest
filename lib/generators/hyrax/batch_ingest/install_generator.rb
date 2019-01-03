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

      source_root File.expand_path('templates', __dir__)

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

      def install_kaminari_views
        generate 'kaminari:views bootstrap3'
      end

      def override_dashboard_sidebar_repository_content
        copy_file "app/views/hyrax/dashboard/sidebar/_repository_content.html.erb", "app/views/hyrax/dashboard/sidebar/_repository_content.html.erb"
        copy_file "spec/views/hyrax/dashboard/batch_sidebar_spec.rb", "spec/views/hyrax/dashboard/batch_sidebar_spec.rb"
      end
    end
  end
end
