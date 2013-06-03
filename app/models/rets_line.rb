class RetsLine < ActiveRecord::Base
  attr_accessible :rets_collection_id, :rets_type, :source, :rets_sysid
  attr_accessible :rets_query_id, :validation_date, :validation_status, :status

  validates_uniqueness_of :rets_sysid
  validates :source, :field => true


  belongs_to :rets_query, inverse_of: :rets_lines





end
