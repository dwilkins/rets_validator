class CreateRetsEditMasks < ActiveRecord::Migration
  def change
    create_table :rets_edit_masks do |t|
      t.integer :rets_collection_id, limit: 25
      t.string :metadata_entry_id, limit: 25
      t.string :edit_mask_id, limit: 25
      t.string :value, limit: 250

      t.timestamps
    end
  end
end
