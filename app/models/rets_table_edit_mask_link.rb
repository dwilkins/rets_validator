class RetsTableEditMaskLink < ActiveRecord::Base
  attr_accessible :rets_edit_mask_id, :rets_table_id

  belongs_to :rets_edit_mask
  belongs_to :rets_table
end
