class RetsEditMask < ActiveRecord::Base
  attr_accessible :edit_mask_id, :metadata_entry_id, :rets_collection_id, :value

  belongs_to :rets_collection

  has_many :rets_table_edit_mask_links
  has_many :rets_tables, through: :rets_table_edit_mask_links, inverse_of: :rets_edit_masks
end
