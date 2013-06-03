class RetsLookupType < ActiveRecord::Base
  attr_accessible :long_value, :metadata_entry_id, :rets_collection_id, :short_value, :value

  belongs_to :rets_collection
  has_one :rets_lookup

end
