class RetsClass < ActiveRecord::Base
  attr_accessible :class_name, :class_time_stamp, :deleted_flag_field, :deleted_flag_value
  attr_accessible :has_key_index, :rets_collection_id, :rets_table_collection_id, :standard_name
  attr_accessible :update_date, :update_version, :visible_name, :description

  belongs_to :rets_collection, conditions: {collection_type: 'RetsClass'}
  belongs_to :rets_table_collection, class_name: 'RetsCollection', conditions: { collection_type: 'RetsTable' }
  has_many :rets_tables, through: :rets_table_collection

end
