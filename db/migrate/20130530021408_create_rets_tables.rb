class CreateRetsTables < ActiveRecord::Migration
  def change
    create_table :rets_tables do |t|
      t.integer :rets_collection_id
      t.string :metadata_entry_id
      t.string :system_name, limit: 25
      t.string :standard_name, limit: 25
      t.string :long_name, limit: 50
      t.string :db_name, limit: 25
      t.string :short_name, limit: 25
      t.integer :maximum_length
      t.string :data_type, limit: 25
      t.integer :precision
      t.boolean :searchable
      t.string :interpretation, limit: 25
      t.string :alignment, limit: 25
      t.boolean :use_separator
      t.integer :rets_lookup_id
      t.integer :max_select
      t.string :units, limit: 25
      t.boolean :index
      t.string :minimum, limit: 25
      t.string :maximum, limit: 25
      t.string :default, limit: 150
      t.boolean :required
      t.string :search_help_id, limit: 25
      t.boolean :unique
      t.datetime :mod_time_stamp
      t.string :foreign_key_naem, limit: 25
      t.string :foreign_field, limit: 25
      t.boolean :in_key_index

      t.timestamps
    end
  end
end
