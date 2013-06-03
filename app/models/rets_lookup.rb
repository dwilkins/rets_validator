class RetsLookup < ActiveRecord::Base
  attr_accessible :date, :lookup_name, :metadata_entry_id, :rets_lookup_type_collection_id
  attr_accessible :rets_collection_id, :version, :visible_name

  belongs_to :rets_collection
  belongs_to :rets_lookup_type_collection, class_name: 'RetsCollection', conditions: { collection_type: 'RetsLookupType' }
  has_many :rets_lookup_types, through: :rets_lookup_type_collection, inverse_of: :rets_lookup

end
