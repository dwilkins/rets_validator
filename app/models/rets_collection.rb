class RetsCollection < ActiveRecord::Base
  attr_accessible :collection_type, :publication_date, :version, :rets_server_id

  has_many :rets_resources, inverse_of: :rets_collection
  has_many :rets_classes, inverse_of: :rets_collection
  has_many :rets_tables, inverse_of: :rets_collection
  has_many :rets_edit_masks, inverse_of: :rets_collection
  has_many :rets_lookup_types, inverse_of: :rets_collection
  has_many :rets_lookups, inverse_of: :rets_collection
  has_many :rets_objects, inverse_of: :rets_collection

end
