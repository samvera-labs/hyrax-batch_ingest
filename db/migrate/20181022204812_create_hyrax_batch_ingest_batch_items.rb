class CreateHyraxBatchIngestBatchItems < ActiveRecord::Migration[5.1]
  def change
    create_table :hyrax_batch_ingest_batch_items do |t|

      t.references :batch, foreign_key: true
      t.string :id_within_batch
      t.string :source_data
      t.string :source_location
      t.string :status
      t.text :error
      t.string :object_id

      t.timestamps
    end
  end
end
