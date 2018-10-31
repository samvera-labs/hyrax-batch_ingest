class AddIngestTypeToHyraxBatchIngestBatches < ActiveRecord::Migration[5.1]
  def change
    add_column :hyrax_batch_ingest_batches, :ingest_type, :string
  end
end
