class RetsResource < ActiveRecord::Base
  attr_accessible :class_count, :description, :key_field, :resource_id
  attr_accessible :rets_class_collection_id, :rets_collection_id
  attr_accessible :rets_edit_mask_collection_id, :rets_lookup_collection_id
  attr_accessible :rets_object_collection_id, :search_help_date
  attr_accessible :search_help_version, :standard_name, :update_help_date
  attr_accessible :update_help_version, :validation_expression_date
  attr_accessible :validation_expression_version, :visible_name
  attr_accessible :rets_class_collection_id
  attr_accessible :rets_edit_mask_collection_id


  belongs_to :rets_collection
  belongs_to :rets_class_collection, class_name: 'RetsCollection', conditions: { collection_type: 'RetsClass' }
  belongs_to :rets_edit_mask_collection, class_name: 'RetsCollection', conditions: { collection_type: 'RetsEditMask' }
  belongs_to :rets_object_collection, class_name: 'RetsCollection', conditions: { collection_type: 'RetsObject' }
  belongs_to :rets_lookup_collection, class_name: 'RetsCollection', conditions: { collection_type: 'RetsLookup' }
  has_many :rets_classes, through: :rets_class_collection
  has_many :rets_edit_masks, through: :rets_edit_mask_collection
  has_many :rets_lookups, through: :rets_lookup_collection
  has_many :rets_objects, through: :rets_object_collection


end
