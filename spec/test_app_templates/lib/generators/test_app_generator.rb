# frozen_string_literal: true
require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  # This is run under .internal_test_app/lib/generators/test_app_generator.rb,
  # so the source_root needs to be sure to specify spec/test_app_templates
  # relative to the gem's root, and not the test app's root.
  source_root File.expand_path('../../../spec/test_app_templates', File.dirname(__FILE__))

  def require_bootsnap
    inject_into_file 'config/boot.rb', after: "require 'bundler/setup' # Set up gems listed in the Gemfile.\n" do
      "require 'bootsnap/setup'\n"
    end
  end

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
    copy_file 'config/example_batch_ingest.yml', 'config/batch_ingest.yml'
  end

  def generate_work_type
    generate 'hyrax:work GenericWork'
  end
end
