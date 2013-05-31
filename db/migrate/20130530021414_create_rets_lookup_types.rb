class CreateRetsLookupTypes < ActiveRecord::Migration
  def change
    create_table :rets_lookup_types do |t|
      t.integer :rets_collection_id
      t.string :metadata_entry_id, limit: 25
      t.string :long_value, limit: 500
      t.string :short_value, limit: 50
      t.string :value, limit: 500

      t.timestamps
    end
  end
end
