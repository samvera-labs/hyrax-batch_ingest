class AddRepoObjectClassNameToBatchItems < ActiveRecord::Migration[5.1]
  def change
    add_column :hyrax_batch_ingest_batch_items, :repo_object_class_name, :string
  end
end
