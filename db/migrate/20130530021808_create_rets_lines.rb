class CreateRetsLines < ActiveRecord::Migration
  def change
    create_table :rets_lines do |t|
      t.integer :rets_collection_id
      t.integer :rets_query_id
      t.integer :rets_sysid
      t.integer :status
      t.string :rets_type, limit: 25
      t.string :source, limit: 65000
      t.datetime :validation_date
      t.integer :validation_status

      t.timestamps
    end
  end
end
