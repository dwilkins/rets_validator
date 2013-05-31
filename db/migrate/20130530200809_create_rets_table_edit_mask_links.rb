class CreateRetsTableEditMaskLinks < ActiveRecord::Migration
  def change
    create_table :rets_table_edit_mask_links do |t|
      t.integer :rets_table_id, null: false
      t.integer :rets_edit_mask_id, null: false

      t.timestamps
    end
  end
end
