# hyrax-batch_ingest
Batch Ingest Plugin for Hyrax

## Installing

1. Add the Hyrax Batch Ingest gem to your Gemfile

   ```ruby
   # in your Gemfile
   gem 'hyrax-batch_ingest'
   ```

1. Run bundle install

   ```
   # from your application's root directory...
   bundle install
   ```

1. Run the Hyrax Batch Ingest installer

   ```
   # from your application's root directory...
   bundle exec hyrax:batch_ingest:install
   ```

   The installer does a few things:
   * Adds batch ingest routes:
      * `/batches` will list all batches.
      * `/batches/[batch_id]` will show details for a batch, including a list of all batch items.
      * `/batches/[batch_id]/items/[batch_item_id]` will show details for single batch item within a batch.
   * Adds database migrations.
   * Includes `Hyrax::BatchIngest::Ability` in your applicaton's `Ability` class at `app/models/ability.rb`.

1. Run database migrations

   ```
   # from your application's root directory...
   bundle exec rails db:migrate
   ```

## Configuration

By default, Hyrax Batch Ingest will try to load configuration from `config/batch_ingest.yml`.

You can tell Hyrax Batch Ingest to load a different configuration file at runtime like this:

```ruby
# Inline syntax
Hyrax::BatchIngest.config.load_config('path/to/your_batch_ingest_config.yml')

# Block syntax, useful if you have additional configuration to set at runtime.
Hyrax::BatchIngest.configure do |config|
  config.load_config('path/to/your_batch_ingest_config.yml')
  # additional config...
end
```

### Ingest Types

Each Bach Ingest has a specific type. The **ingest type** determines how the batch should be read into the system, and how it should be mapped to the persistence layer (i.e. Fedora)
