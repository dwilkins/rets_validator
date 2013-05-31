class CreateRetsLookups < ActiveRecord::Migration
  def change
    create_table :rets_lookups do |t|
      t.integer :rets_collection_id, limit: 25
      t.string :metadata_entry_id, limit: 25
      t.string :lookup_name, limit: 25
      t.integer :rets_lookup_type_collection_id
      t.string :visible_name, limit: 25
      t.string :version, limit: 25
      t.datetime :date

      t.timestamps
    end
  end
end
