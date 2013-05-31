class RetsLine < ActiveRecord::Base
  attr_accessible :rets_collection_id, :rets_type, :source, :rets_sysid
  attr_accessible :rets_query_id, :validation_date, :validation_status, :status
end
