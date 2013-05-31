# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130530200809) do

  create_table "rets_classes", :force => true do |t|
    t.integer  "rets_collection_id"
    t.string   "class_name",               :limit => 50
    t.string   "standard_name",            :limit => 50
    t.string   "visible_name",             :limit => 50
    t.string   "description",              :limit => 150
    t.integer  "rets_table_collection_id"
    t.string   "update_version",           :limit => 25
    t.datetime "update_date"
    t.datetime "class_time_stamp"
    t.string   "deleted_flag_field",       :limit => 25
    t.string   "deleted_flag_value",       :limit => 25
    t.boolean  "has_key_index"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  create_table "rets_collections", :force => true do |t|
    t.string   "collection_type",  :limit => 25
    t.datetime "publication_date"
    t.string   "version",          :limit => 25
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "rets_edit_masks", :force => true do |t|
    t.integer  "rets_collection_id"
    t.string   "metadata_entry_id",  :limit => 25
    t.string   "edit_mask_id",       :limit => 25
    t.string   "value",              :limit => 250
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "rets_lines", :force => true do |t|
    t.integer  "rets_collection_id"
    t.integer  "rets_query_id"
    t.integer  "rets_sysid"
    t.integer  "status"
    t.string   "rets_type",          :limit => 25
    t.text     "source",             :limit => 16777215
    t.datetime "validation_date"
    t.integer  "validation_status"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  create_table "rets_lookup_types", :force => true do |t|
    t.integer  "rets_collection_id"
    t.string   "metadata_entry_id",  :limit => 25
    t.string   "long_value",         :limit => 500
    t.string   "short_value",        :limit => 50
    t.string   "value",              :limit => 500
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "rets_lookups", :force => true do |t|
    t.integer  "rets_collection_id"
    t.string   "metadata_entry_id",              :limit => 25
    t.string   "lookup_name",                    :limit => 25
    t.integer  "rets_lookup_type_collection_id"
    t.string   "visible_name",                   :limit => 25
    t.string   "version",                        :limit => 25
    t.datetime "date"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  create_table "rets_objects", :force => true do |t|
    t.integer  "rets_collection_id"
    t.string   "metadata_entry_id",  :limit => 25
    t.string   "object_type",        :limit => 25
    t.string   "mime_type",          :limit => 25
    t.string   "visible_name",       :limit => 25
    t.string   "description",        :limit => 150
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "rets_queries", :force => true do |t|
    t.integer  "rows_returned"
    t.integer  "error_code"
    t.string   "error_message", :limit => 1000
    t.string   "options",       :limit => 3000
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "rets_resources", :force => true do |t|
    t.integer  "rets_collection_id"
    t.string   "resource_id",                   :limit => 25
    t.string   "standard_name",                 :limit => 50
    t.string   "visible_name",                  :limit => 50
    t.string   "description",                   :limit => 150
    t.string   "key_field",                     :limit => 10
    t.integer  "class_count"
    t.integer  "rets_class_collection_id"
    t.integer  "rets_object_collection_id"
    t.string   "search_help_version",           :limit => 25
    t.datetime "search_help_date"
    t.integer  "rets_edit_mask_collection_id"
    t.integer  "rets_lookup_collection_id"
    t.string   "update_help_version",           :limit => 25
    t.datetime "update_help_date"
    t.string   "validation_expression_version", :limit => 25
    t.datetime "validation_expression_date"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  create_table "rets_table_edit_mask_links", :force => true do |t|
    t.integer  "rets_table_id",     :null => false
    t.integer  "rets_edit_mask_id", :null => false
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "rets_tables", :force => true do |t|
    t.integer  "rets_collection_id"
    t.string   "metadata_entry_id"
    t.string   "system_name",        :limit => 25
    t.string   "standard_name",      :limit => 25
    t.string   "long_name",          :limit => 50
    t.string   "db_name",            :limit => 25
    t.string   "short_name",         :limit => 25
    t.integer  "maximum_length"
    t.string   "data_type",          :limit => 25
    t.integer  "precision"
    t.boolean  "searchable"
    t.string   "interpretation",     :limit => 25
    t.string   "alignment",          :limit => 25
    t.boolean  "use_separator"
    t.integer  "rets_lookup_id"
    t.integer  "max_select"
    t.string   "units",              :limit => 25
    t.boolean  "index"
    t.string   "minimum",            :limit => 25
    t.string   "maximum",            :limit => 25
    t.string   "default",            :limit => 150
    t.boolean  "required"
    t.string   "search_help_id",     :limit => 25
    t.boolean  "unique"
    t.datetime "mod_time_stamp"
    t.string   "foreign_key_naem",   :limit => 25
    t.string   "foreign_field",      :limit => 25
    t.boolean  "in_key_index"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

end
