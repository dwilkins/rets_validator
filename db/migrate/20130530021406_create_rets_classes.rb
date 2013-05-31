class CreateRetsClasses < ActiveRecord::Migration
  def change
    create_table :rets_classes do |t|
      t.integer :rets_collection_id
      t.string :class_name, limit: 50
      t.string :standard_name, limit: 50
      t.string :visible_name, limit: 50
      t.string :description, limit: 150
      t.integer :rets_table_collection_id
      t.string :update_version, limit: 25
      t.datetime :update_date
      t.datetime :class_time_stamp
      t.string :deleted_flag_field, limit: 25
      t.string :deleted_flag_value, limit: 25
      t.boolean :has_key_index

      t.timestamps
    end
  end
end
