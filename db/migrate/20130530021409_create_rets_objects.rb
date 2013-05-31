class CreateRetsObjects < ActiveRecord::Migration
  def change
    create_table :rets_objects do |t|
      t.integer :rets_collection_id
      t.string :metadata_entry_id, limit: 25
      t.string :object_type, limit: 25
      t.string :mime_type, limit: 25
      t.string :visible_name, limit: 25
      t.string :description, limit: 150

      t.timestamps
    end
  end
end
