class CreateHyraxBatchIngestBatches < ActiveRecord::Migration[5.1]
  def change
    create_table :hyrax_batch_ingest_batches do |t|
      t.string :status
      t.string :submitter_email
      t.string :source_location
      t.text :error
      t.string :admin_set_id

      t.timestamps
    end
  end
end
