$:.push File.expand_path("../lib", __FILE__)

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

  s.add_dependency "rails", "~> 5.1.6"
  s.add_dependency "hyrax", "~> 2.2.0"
  # This needs to be pinned to 11.5.2 because Hyrax won't install otherwise,
  # because of some bizzare error eraised in cases where AF is *not* 11.5.2.
  s.add_dependency "active-fedora", "11.5.2"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails", "~> 3.8"
end
