class RetsObject < ActiveRecord::Base
  attr_accessible :description, :metadata_entry_id, :mime_type, :object_type, :rets_collection_id, :visible_name

  belongs_to :rets_collection

end
