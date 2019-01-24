class ChangeSourceDataToText < ActiveRecord::Migration[5.1]
  def change
    change_column :hyrax_batch_ingest_batch_items, :source_data, :text
  end
end
