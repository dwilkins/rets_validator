class RetsLine < ActiveRecord::Base
  attr_accessible :rets_collection_id, :rets_type, :source, :rets_sysid
  attr_accessible :rets_query_id, :validation_date, :validation_status, :status

  validates_uniqueness_of :rets_sysid

  belongs_to :rets_query, inverse_of: :rets_lines
  has_many :rets_line_errors

  scope :unvalidated, where(status: -1)
  scope :validated, where("status != -1")


  def log_errors
    fields = YAML.load(self.source)
    query  = self.rets_query
    query_options = YAML.load(query.options)
    @@rets_fields ||= {}
    if @@rets_fields.empty?
      rets_class_collections = RetsCollection.where(collection_type: 'RetsClass', rets_server_id: query.rets_server_id)
      rets_class_collection_ids = rets_class_collections.collect {|rcc| rcc.id }

      rets_classes = RetsClass.where(class_name: query_options[:class]).where(rets_collection_id: rets_class_collection_ids)
      rets_classes[0].rets_tables.includes(:rets_lookup).includes(:rets_lookup => [:rets_lookup_types]).each do |rt|
        @@rets_fields[rt.system_name] = rt
      end
    end

    decoded = query_options[:format] == 'COMPACT_DECODED' ? true : false
    # remove old errors
    self.rets_line_errors.each { |rle| rle.destroy }

    errors = []

#    system_names = fields.collect { |k,v| k }
#    rets_fields = {}
#    RetsTable.where(system_name: system_names).includes(:rets_lookup).includes(:rets_lookup => [:rets_lookup_types]).each do |rt|
#      rets_fields[rt.system_name] = rt
#    end

    ActiveRecord::Base.transaction do
      fields.each do |f,v|
        field_def = @@rets_fields[f]

        error = false
        if field_def.rets_lookup
          if field_def.interpretation == 'LookupMulti'
            field_values = v.split(",")
          else
            field_values = [v]
          end
          field_values.each do |fv|
            fv.tr! "\"",""
            fv.strip!
            if !field_def.valid_value? fv
              errors << RetsLineError.create(rets_line_id: self.id,
                                             rets_table_id: field_def.id,
                                             error: "LOOKUP ERROR on field #{f} - \"#{field_def.long_name}\" value \"#{fv}\" not in #{field_def.valid_values(decoded).to_s(',')}")
            end
          end
        end
      end
    end
    errors
  end

end
