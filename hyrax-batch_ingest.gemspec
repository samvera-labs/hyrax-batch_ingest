# frozen_string_literal: true
$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "hyrax/batch_ingest/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "hyrax-batch_ingest"
  s.version     = Hyrax::BatchIngest::VERSION
  s.authors     = ["Andrew Myers"]
  s.email       = ["andrew_myers@wgbh.org"]
  s.homepage    = "https://github.com/samvera-labs/hyrax-batch_ingest"
  s.summary     = "Batch ingest support for Hyrax applications"
  s.description = "Batch ingest support for Hyrax applications"
  s.license     = "Apache-2.0"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency 'rails', '~> 5.1.6'
  s.add_dependency 'hyrax', '~> 2.2'

  s.add_development_dependency 'bixby'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'codeclimate-test-reporter'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'factory_bot_rails', '~> 4.11'
  s.add_development_dependency 'fcrepo_wrapper'
  s.add_development_dependency 'rspec-rails', '~> 3.8'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'solr_wrapper'
  s.add_development_dependency 'sqlite3'

  # Pinned dependencies
  s.add_development_dependency 'sass', '=3.6.0'
end
