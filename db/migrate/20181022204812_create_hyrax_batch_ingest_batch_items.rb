class CreateHyraxBatchIngestBatchItems < ActiveRecord::Migration[5.1]
  def change
    create_table :hyrax_batch_ingest_batch_items do |t|
      t.references :batch, foreign_key: true
      t.string :name
      t.string :source_data
      t.string :source_location
      t.string :status
      t.string :error_message

      t.timestamps
    end
  end
end
