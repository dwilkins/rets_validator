class FieldValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    fields = YAML.load(value)
    query  = RetsQuery.find(record.rets_query_id)
    query_parms = query.options
    decoded = options[:format] == 'COMPACT_DECODED' ? true : false


    errors = []

    system_names = fields.collect { |k,v| k }
    rets_fields = {}
    RetsTable.where(system_name: system_names).includes(:rets_lookup).includes(:rets_lookup => [:rets_lookup_types]).each do |rt|
      rets_fields[rt.system_name] = rt
    end

    fields.each do |f,v|
      field_def = rets_fields[f]

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
          valid_values = field_def.rets_lookup.rets_lookup_types.collect { |lt| (decoded ? lt.value.strip : lt.long_value.strip)  }
          if((fv && !fv.empty? && !valid_values.include?(fv)) ||
             (fv && fv.empty? && field_def.required))
            record.errors[f.intern] << "ERROR on field #{f} - \"#{field_def.long_name}\" value \"#{fv}\" not in #{valid_values.to_s(',')}"
          else fv && !fv.empty?
            #          puts "Sweet -  field #{field} - #{field_def['LongName']} value #{fv} is in #{valid_values.to_s(',')}"
          end
        end
      end
    end
  end
end
#class Person < ActiveRecord::Base
#  validates :email, :presence => true, :email => true
#end
