# frozen_string_literal: true
require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root "./spec/test_app_templates"

  # if you need to generate any additional configuration
  # into the test app, this generator will be run immediately
  # after setting up the application
  def install_hyrax
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

  # TODO: BROKEN - NEEDS TO RUN AFTER FEDORA/SOLR HAVE STARTED.
  def create_default_admin_set
    rake 'hyrax:default_admin_set:create'
  end

  def add_example_batch_ingest_config
    # TODO: the line below doesn't work. Currently need to copy by hand .
    copy_file 'config/example_batch_ingest.yml', 'config/batch_ingest.yml'
  end

  def add_admin_user
    # TODO
  end
end
