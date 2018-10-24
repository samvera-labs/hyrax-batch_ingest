# frozen_string_literal: true
require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root "./spec/test_app_templates"

  # if you need to generate any additional configuration
  # into the test app, this generator will be run immediately
  # after setting up the application
  def install_hyrax
    # Need to require 'rails/generators/actions' before hyrax:install:migrations generator is run
    require 'rails/generators/actions'
    generate 'hyrax:install -f'
  end

  def fix_hyrax_install
    # Need to require 'rails/generators/actions' before hyrax:install:migrations generator is run
    require 'rails/generators/actions'
    Hyrax::DatabaseMigrator.copy
    rake('db:migrate')
  end

  def install_engine
    generate 'hyrax:batch_ingest:install'
  end
end
