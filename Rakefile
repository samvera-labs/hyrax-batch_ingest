# frozen_string_literal: true
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Hyrax::BatchIngest'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

load 'rails/tasks/statistics.rake'
require 'bundler/gem_tasks'

# Create rake task for RSpec
begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  puts 'You must add `rspec` to your Gemfile and run `bundle install` to run this rake task'
end

require 'engine_cart/rake_task'
task ci: [:rubocop, 'engine_cart:generate'] do
  Rake::Task[:spec].invoke
end

# APP_RAKEFILE = File.expand_path("../.internal_test_app/Rakefile", __FILE__)

# load 'rails/tasks/engine.rake'

begin
  require 'rubocop/rake_task'
  desc 'Run style checker'
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.fail_on_error = true
  end
rescue LoadError
  puts 'You must add `rubocop` to your Gemfile and run `bundle install` to run this rake task'
end

# Set default rake task to use RSpec rake task
task default: [:ci]
