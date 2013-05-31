class CreateRetsResources < ActiveRecord::Migration
  def change
    create_table :rets_resources do |t|
      t.integer :rets_collection_id
      t.string :resource_id, limit: 25
      t.string :standard_name, limit: 50
      t.string :visible_name, limit: 50
      t.string :description, limit: 150
      t.string :key_field, limit: 10
      t.integer :class_count
      t.integer :rets_class_collection_id
      t.integer :rets_object_collection_id
      t.string :search_help_version, limit: 25
      t.datetime :search_help_date
      t.integer :rets_edit_mask_collection_id
      t.integer :rets_lookup_collection_id
      t.string :update_help_version, limit: 25
      t.datetime :update_help_date
      t.string :validation_expression_version, limit: 25
      t.datetime :validation_expression_date

      t.timestamps
    end
  end
end
