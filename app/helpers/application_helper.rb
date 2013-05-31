module ApplicationHelper

  # rets_defs is a big 'ole nasty hash for the time being

  def validate_rets rets_defs,table, field, value

    field_def = rets_defs[table][:system_names][field]

    error = false
    if field_def[:lookup_type] && !field_def[:lookup_type].empty?
      if field_def['Interpretation'] == 'LookupMulti'
        field_values = value.split(",")
      else
        field_values = [value]
      end
      field_values.each do |fv|
        fv.tr! "\"",""
        fv.strip!
#        valid_values = field_def[:lookup_type][:values].collect { |k,v| v["LongValue"].strip }
        valid_values = field_def[:lookup_type][:values].collect { |k,v| v["Value"].strip }
        if((fv && !fv.empty? && !valid_values.include?(fv)) ||
           (fv && fv.empty? && field_def["Required"] != '0'))
          puts "ERROR on field #{field} - #{field_def['LongName']} value #{fv} not in #{valid_values.to_s(',')}"
          error = true
        else fv && !fv.empty?
#          puts "Sweet -  field #{field} - #{field_def['LongName']} value #{fv} is in #{valid_values.to_s(',')}"
        end
      end
    end
    if field_def[:masks]
      error = true
      field_def[:masks].each do |k,mask|
        pat = Regexp.new(mask["Value"])
        if ((value && !value.empty? && pat =~ value) ||
            (((value && value.empty?) || value.nil?) && field_def["Required"] == '0'))
          error = false
        end
      end
      if(error)
        puts "ERROR on field #{field} - #{field_def['LongName']} value #{value} did not match edit masks of #{field_def[:masks].collect do |k,em| em['Value'] end.to_s(',')}"
      end
    end
    if field_def['Maximumlength'] && !field_def['Maximumlength'].empty?
      if value && value.length > field_def['Maximumlength']
        puts "ERROR on field #{field} - #{field_def['LongName']} value #{value} exceeds MaximumLength of #{field_def['Maximumlength']}"
      end
    end
    if field_def['DataType'] == 'Int'
      if field_def['Required']
        pat = Regexp.new(/^\s*(\d*)\s*$/)
      else
        pat = Regexp.new(/^\s*(\d+)\s*$/)
      end
      if value && !value.match(pat)
        puts "ERROR on field #{field} - #{field_def['LongName']} value \"#{value}\" has non-integer values"
      end
    end
  end



end
