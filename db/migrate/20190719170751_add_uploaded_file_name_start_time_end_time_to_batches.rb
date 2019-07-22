class AddUploadedFileNameStartTimeEndTimeToBatches < ActiveRecord::Migration[5.1]
  def change
    add_column :hyrax_batch_ingest_batches, :uploaded_filename, :string
    add_column :hyrax_batch_ingest_batches, :start_time, :datetime
    add_column :hyrax_batch_ingest_batches, :end_time, :datetime
  end
end
