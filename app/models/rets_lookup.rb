class RetsLookup < ActiveRecord::Base
  attr_accessible :date, :lookup_name, :metadata_entry_id, :rets_lookup_type_collection_id
  attr_accessible :rets_collection_id, :version, :visible_name

  belongs_to :rets_collection

end
