class RetsTable < ActiveRecord::Base
  attr_accessible :alignment, :data_type, :db_name, :default
  attr_accessible :foreign_field, :foreign_key_name
  attr_accessible :in_key_index, :index, :interpretation, :long_name
  attr_accessible :rets_lookup_id, :max_select, :maximum, :maximum_length
  attr_accessible :metadata_entry_id, :minimum, :mod_time_stamp
  attr_accessible :precision, :required, :rets_collection_id, :search_help_id
  attr_accessible :searchable, :short_name, :standard_name, :system_name
  attr_accessible :unique, :units, :use_separator

  belongs_to :rets_lookup
  belongs_to :rets_collection, conditions: {collection_type: 'RetsTable'}

  has_many :rets_table_edit_mask_links
  has_many :rets_edit_masks, through: :rets_table_edit_mask_links, inverse_of: :rets_tables

end
