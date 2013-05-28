require 'active_record'
require 'active_support/all'

namespace :import do
  desc 'Get some RETS data'
  task :rets => :environment do
    include ApplicationHelper
    if ENV['RETS_USER'].nil? || ENV['RETS_USER'].empty? || ENV['RETS_PASSWORD'].nil? || ENV['RETS_PASSWORD'].empty?
      puts "Please set the RETS_USER and RETS_PASSWORD environment variables and run again"
      next
    end
    client = RETS::Client.login(:url => "http://glvar.apps.retsiq.com/rets/login", :username => ENV['RETS_USER'], :password => ENV['RETS_PASSWORD'])
    if File.exists? 'rets.yml'
      tables = File.open('rets.yml'){ |rets_data| YAML.load rets_data }
    else
      resources = {}
      rets_classes = {}
      tables = {}
      lookups = {}
      lookup_types = {}
      edit_masks = {}
      client.get_metadata({type: 'METADATA-SYSTEM', id: '*', }) do |type, attrs, metadata|
        if type == 'RESOURCE'
          resources = {}
          resources[:version] = attrs["Version"]
          resources[:date] = attrs["Date"]
          resources[:names] = {}
          metadata.each do |m|
            m[:rets_class] = {}
            m[:lookup] = {}
            resources[:names][m['ResourceID']] = m
          end
        end
        if type == 'CLASS'
          rets_class = {}
          rets_class[:version] = attrs["Version"]
          rets_class[:date] = attrs["Date"]
          rets_class[:resource] = resources[:names][attrs["Resource"]]
          rets_class[:names] = {}
          metadata.each do |m|
            rets_class[:names][m['ClassName']] = m
          end
          resources[:names][attrs["Resource"]][:rets_class] = rets_class
        end
        if type == 'TABLE'
          table = {}
          table[:resource] = resources[:names][attrs["Resource"]]
          table[:class] = table[:resource][:rets_class][:names][attrs["Class"]]
          table[:version] = attrs["Version"]
          table[:date] = attrs["Date"]
          table[:fields] = {}
          metadata.each do |m|
           table[:fields][m["MetadataEntryID"]] = m
          end
          tables["Table-" + attrs["Class"] + "-" + attrs["Resource"]] = table
        end
        if type == 'LOOKUP'
          lookup = {}
          lookup[:version] = attrs["Version"]
          lookup[:date] = attrs["Date"]
          lookup[:resource] = resources[:names][attrs["Resource"]]
          lookup[:names] = {}
          metadata.each do |m|
            lookup[:names][m["LookupName"]] = m
          end
          resources[:names][attrs["Resource"]][:lookup] = lookup
          lookups[attrs["Resource"]] = lookup
        end
        if type == 'LOOKUP_TYPE'
          lookup_type = {}
          lookup_type[:version] = attrs["Version"]
          lookup_type[:date] = attrs["Date"]
          lookup_type[:resource] = resources[:names][attrs["Resource"]]
          lookup_type[:lookup_name] = attrs['Lookup']
          lookup_type[:lookup] = lookups[attrs["Resource"]][:names][attrs['Lookup']]
          lookup_type[:values] = {}
          metadata.each do |m|
            lookup_type[:values][m["MetadataEntryID"]] = m
          end
          lookup_types[attrs["Resource"]] = lookup
          lookups[attrs["Resource"]][:names][attrs['Lookup']][:lookup_type] = lookup_type
        end
        if type == 'EDITMASK'
          edit_mask = {}
          edit_mask[:version] = attrs["Version"]
          edit_mask[:date] = attrs["Date"]
          edit_mask[:resource] = resources[:names][attrs["Resource"]]
          edit_mask[:fields] = {}
          metadata.each do |m|
            edit_mask[:fields][m["MetadataEntryID"]] = m
          end
          edit_masks[attrs["Resource"]] = edit_mask
          resources[:names][attrs["Resource"]][:edit_mask] = edit_mask
        end
      end
      tables.each do |t,tv|
        tv[:system_names] ||= {}
        tv[:fields].each do |f,fv|
          if !fv["EditMaskID"].empty?
            masks = fv["EditMaskID"].split(',')
            fv[:masks] = {}
            masks.each do |em|
              fv[:masks][em] =  tv[:resource][:edit_mask][:fields][em]
            end
          end
          if !fv["LookupName"].empty?
            fv[:lookup_type] = tv[:resource][:lookup][:names][fv["LookupName"]][:lookup_type]
          end
          tv[:system_names][fv["SystemName"]] = fv
        end
      end
      File.open( 'rets.yml', 'w' ) do |out|
        YAML.dump(tables, out )
      end
    end
    fields = tables['Table-1-Property'][:system_names].collect { |k,v| k if k != '12' && k != "2906" }
    client.search(:search_type => :Property, class: 1, query: "(144=50000-)", select: fields, standard_names: false, limit: 100) do |data|
      data.each do |k,v|
        validate_rets tables,'Table-1-Property',k,v
      end
      puts data
    end
  end
end
