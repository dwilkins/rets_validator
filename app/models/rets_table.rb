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
  belongs_to :rets_collection, conditions: {collection_type: 'RetsTable'}, inverse_of: :rets_tables

#  has_one  :rets_table_collection, foreign_key: rets_table_collection_id, through: :rets_table_collection, class_name: 'RetsClass'
  has_one :rets_class, foreign_key: :rets_table_collection_id,primary_key: :rets_collection_id,  class_name: 'RetsClass', inverse_of: :rets_table_collection
  has_many :rets_table_edit_mask_links
  has_many :rets_edit_masks, through: :rets_table_edit_mask_links, inverse_of: :rets_tables

  scope :for_class, lambda{|rets_class| joins(:rets_class).where(rets_classes: {class_name: rets_class } ) }

end
