class RenameColumnHyraxBatchIngestBatchItems < ActiveRecord::Migration[5.1]
  def change
    rename_column :hyrax_batch_ingest_batch_items, :object_id, :repo_object_id
  end
end
