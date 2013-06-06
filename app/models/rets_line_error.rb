class RetsLineError < ActiveRecord::Base
  attr_accessible :error, :rets_line_id, :rets_table_id

  belongs_to :rets_line
  belongs_to :rets_table


end
