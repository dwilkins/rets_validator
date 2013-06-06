class AddImportantIndexes < ActiveRecord::Migration
  def up
    add_index :rets_lines, [:rets_sysid], unique: true
    add_index :rets_classes, [:standard_name]
    add_index :rets_classes, [:rets_table_collection_id]
    add_index :rets_tables, [:rets_collection_id]
    add_index :rets_tables, [:rets_lookup_id]

    add_index :rets_table_edit_mask_links, [:rets_table_id, :rets_edit_mask_id], {name: 'index_rteml_on_rets_table_id_and_rets_edit_mask_id', unique: true}


  end

  def down
  end
end
