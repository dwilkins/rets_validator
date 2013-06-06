require 'active_record'
require 'active_support/all'

namespace :rets do
  desc 'Get some RETS metadata'
  task :metadata, [:server_in] => :environment do |tsk, args|
    args.with_defaults(:server_in => "")
#  task :rets => :environment do
    include ApplicationHelper
    if !args[:server_in].empty?
      server = RetsServer.find_by_name(args[:server_in])
      if server.nil?
        server = RetsServer.find(args[:server_in].to_i)
      end
    end

    if args[:server_in].nil? || args[:server_in].empty? || server.nil?
      puts "Please specify a server name like:"
      puts "   rake import:rets[SERVERNAME]]"
      puts "   rake import:rets[SERVERID]]"
      servers = RetsServer.all
      if !servers.nil? && !servers.empty?
        servers.each do |srvr|
          puts "    rake import:rets[#{srvr.name}]"
          puts "    or"
          puts "    rake import:rets[#{srvr.id}]"
        end
      else
        puts " NO SERVERS DEFINED IN rets_servers in the db"
      end
      next
    end
    begin
      client = RETS::Client.login(url: server.login_url,
                                  username: server.username,
                                  password: server.password)
    rescue Exception => e
      puts "Error #{e.message} connecting"
      next
    end
    if !client.nil? && !client.rets_data.nil? && client.rets_data.nil[:code].to_i > 0
      puts ((client.nil? || client.rets_data.nil?)  ? "problem connecting to #{ENV['RETS_URL']}" : client.rets_data[:text])
      next
    end
    File.open( 'rets.metadata.yml', 'w' ) do |out|
      out.write("\n")
    end
    begin
      resources = {}
      rets_classes = {}
      tables = {}
      lookups = {}
      lookup_types = {}
      types = {}
      edit_masks = {}
      client.get_metadata({type: 'METADATA-SYSTEM', id: '*', }) do |type, attrs, metadata|
        metadata.each do |m|
          types[type] ||= m.collect do |k,v|
            k.underscore + ": m[\"" + k + "\"]"
          end
          break
        end
        File.open( 'rets.metadata.yml', 'a' ) do |out|
          YAML.dump({type: type, attrs: attrs, metadata: metadata},out )
        end

        if type == 'RESOURCE'
          resources = {}
          resources[:version] = attrs["Version"]
          resources[:date] = attrs["Date"]
          resources[:names] = {}
          resource_collection = RetsCollection.create(rets_server_id: server.id,
                                                      collection_type: 'RetsResource',
                                                      publication_date: attrs['Date'],
                                                      version: attrs['Version'])
          metadata.each do |m|
            m[:rets_class] = {}
            m[:lookup] = {}
            resources[:names][m['ResourceID']] = m
            RetsResource.create(rets_collection_id: resource_collection.id,
                                resource_id: m['ResourceID'],
                                standard_name: m['StandardName'],
                                visible_name: m['VisibleName'],
                                description: m['Description'],
                                key_field: m['KeyField'],
                                class_count: m['ClassCount'],
                                search_help_version: m['SearchHelpVersion'],
                                search_help_date: m['SearchHelpDate'],
                                update_help_version: m['UpdateHelpVersion'],
                                update_help_date: m['UpdateHelpDate'],
                                validation_expression_version: m['ValidationExpressionVersion'],
                                validation_expression_date: m['ValidationExpressionDate']
                                )
          end
        end
        if type == 'CLASS'
          rets_class = {}
          rets_class[:version] = attrs["Version"]
          rets_class[:date] = attrs["Date"]
          rets_class[:resource] = resources[:names][attrs["Resource"]]
          rets_class[:names] = {}
          this_resource = RetsResource.where(resource_id: attrs['Resource']).first
          class_collection = RetsCollection.create(rets_server_id: server.id,
                                                   collection_type: 'RetsClass',
                                                   publication_date: attrs['Date'],
                                                   version: attrs['Version'])
          this_resource.rets_class_collection_id = class_collection.id
          this_resource.save
          metadata.each do |m|
            rets_class[:names][m['ClassName']] = m
            RetsClass.create(rets_collection_id: class_collection.id,
                             class_name: m['ClassName'],
                             standard_name: m['StandardName'],
                             visible_name: m['VisibleName'],
                             description: m['Description'],
                             update_version: m['UpdateVersion'],
                             update_date: m['UpdateDate'],
                             class_time_stamp: m['ClassTimeStamp'],
                             deleted_flag_field: m['DeletedFlagField'],
                             deleted_flag_value: m['DeletedFlagValue'],
                             has_key_index: m['HasKeyIndex'])
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
          this_collection = RetsCollection.create(rets_server_id: server.id,
                                                  collection_type: 'RetsTable',
                                                  publication_date: attrs['Date'],
                                                  version: attrs['Version'])
          this_class = RetsClass.where(class_name: attrs['Class']).first
          this_class.rets_table_collection_id = this_collection.id
          this_class.save
          metadata.each do |m|
            table[:fields][m["MetadataEntryID"]] = m
            rets_lookup_id  = nil
            if m['LookupName'] && !m['LookupName'].empty?
              rets_lookup = RetsLookup.find_or_create_by_lookup_name(m['LookupName'])
              rets_lookup_id = rets_lookup.id
            end
            this_table = RetsTable.create(rets_collection_id: this_collection.id,
                                          metadata_entry_id: m['MetadataEntryID'],
                                          system_name: m['SystemName'],
                                          standard_name: m['StandardName'],
                                          long_name: m['LongName'],
                                          db_name: m['DBName'],
                                          short_name: m['ShortName'],
                                          maximum_length: m['MaximumLength'],
                                          data_type: m['DataType'],
                                          precision: m['Precision'],
                                          searchable: m['Searchable'],
                                          interpretation: m['Interpretation'],
                                          alignment: m['Alignment'],
                                          use_separator: m['UseSeparator'],
                                          rets_lookup_id: rets_lookup_id,
                                          max_select: m['MaxSelect'],
                                          units: m['Units'],
                                          index: m['Index'],
                                          minimum: m['Minimum'],
                                          maximum: m['Maximum'],
                                          default: m['Default'],
                                          required: m['Required'],
                                          search_help_id: m['SearchHelpID'],
                                          unique: m['Unique'],
                                          mod_time_stamp: m['ModTimeStamp'],
                                          in_key_index: m['InKeyIndex']
                                          )
            if m['EditMaskID'] && !m['EditMaskID'].empty?
              m['EditMaskID'].split(',').each do |em|
                edit_mask = RetsEditMask.find_or_create_by_edit_mask_id(em)
                RetsTableEditMaskLink.create(rets_table_id: this_table.id,
                                             rets_edit_mask_id: edit_mask.id)
              end
            end
          end
          tables["Table-" + attrs["Class"] + "-" + attrs["Resource"]] = table
        end
        if type == 'LOOKUP'
          lookup = {}
          lookup[:version] = attrs["Version"]
          lookup[:date] = attrs["Date"]
          lookup[:resource] = resources[:names][attrs["Resource"]]
          lookup[:names] = {}
          this_resource = RetsResource.where(resource_id: attrs['Resource']).first
          this_collection = RetsCollection.create(rets_server_id: server.id,
                                                  collection_type: 'RetsLookup',
                                                  publication_date: attrs['Date'],
                                                  version: attrs['Version'])
          this_resource.rets_lookup_collection_id = this_collection.id
          this_resource.save
          metadata.each do |m|
            lookup[:names][m["LookupName"]] = m
            this_rets_lookup = RetsLookup.find_or_create_by_lookup_name(m['LookupName'])
            this_rets_lookup.assign_attributes(rets_collection_id: this_collection.id,
                                               metadata_entry_id: m['MetadataEntryID'],
                                               rets_lookup_type_collection_id: nil,
                                               visible_name: m['VisibleName'],
                                               version: m['Version'],
                                               date: m['Date'])
            this_rets_lookup.save
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
          this_collection = RetsCollection.create(rets_server_id: server.id,
                                                  collection_type: 'RetsLookupType',
                                                  publication_date: attrs['Date'],
                                                  version: attrs['Version'])
          this_lookup = RetsLookup.where(:lookup_name => attrs['Lookup']).first
          this_lookup.rets_lookup_type_collection_id = this_collection.id
          this_lookup.save
          metadata.each do |m|
            lookup_type[:values][m["MetadataEntryID"]] = m
            RetsLookupType.create(rets_collection_id: this_collection.id,
                                  metadata_entry_id: m['MetadataEntryID'],
                                  long_value: m['LongValue'],
                                  short_value: m['ShortValue'],
                                  value: m['Value'])
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
          this_resource = RetsResource.where(resource_id: attrs['Resource']).first
          this_collection = RetsCollection.create(rets_server_id: server.id,
                                                  collection_type: 'RetsEditMask',
                                                  publication_date: attrs['Date'],
                                                  version: attrs['Version'])
          this_resource.rets_edit_mask_collection_id = this_collection.id
          this_resource.save
          metadata.each do |m|
            edit_mask[:fields][m["MetadataEntryID"]] = m
            rets_edit_mask = RetsEditMask.find_or_create_by_edit_mask_id(m['EditMaskID'])
            rets_edit_mask.assign_attributes(rets_collection_id: this_collection.id,
                                             metadata_entry_id: m['MetadataEntryID'],
                                             edit_mask_id: m['EditMaskID'],
                                             value: m['Value'])
            rets_edit_mask.save
          end
          edit_masks[attrs["Resource"]] = edit_mask
          resources[:names][attrs["Resource"]][:edit_mask] = edit_mask
        end
      end
      tables.each do |t,tv|
        tv[:system_names] ||= {}
        tv[:fields].each do |f,fv|
          if !fv["EditMaskID"].nil? && !fv["EditMaskID"].empty?
            masks = fv["EditMaskID"].split(',')
            fv[:masks] = {}
            masks.each do |em|
              fv[:masks][em] =  tv[:resource][:edit_mask][:fields][em]
            end
          end
          if !fv["LookupName"].nil? && !fv["LookupName"].empty? && !tv[:resource][:lookup][:names].nil?
            fv[:lookup_type] = tv[:resource][:lookup][:names][fv["LookupName"]][:lookup_type]
          end
          tv[:system_names][fv["SystemName"]] = fv
        end
      end
      File.open( 'rets.yml', 'w' ) do |out|
        YAML.dump(tables, out )
      end
      File.open( 'types.yml', 'w' ) do |out|
        YAML.dump(types, out )
      end
    end
  end

  task :data, [:server_in, :query_in, :repeat_in, :class_in] => :environment do |tsk, args|
    args.with_defaults(server_in: '', query_in: '',class_in: '1',repeat_in: '1')
    #  task :rets => :environment do
    include ApplicationHelper
    if !args[:server_in].empty?
      server = RetsServer.find_by_name(args[:server_in])
      if server.nil?
        server = RetsServer.find(args[:server_in].to_i)
      end
    end

    if args[:server_in].nil? || args[:server_in].empty? || server.nil?
      puts "Please specify a server name like:"
      puts "   rake import:rets[SERVERNAME]]"
      puts "   rake import:rets[SERVERID]]"
      servers = RetsServer.all
      if !servers.nil? && !servers.empty?
        servers.each do |srvr|
          puts "    rake import:rets[#{srvr.name}]"
          puts "    or"
          puts "    rake import:rets[#{srvr.id}]"
        end
      else
        puts " NO SERVERS DEFINED IN rets_servers in the db"
      end
      next
    end
    if args[:query_in].empty?
      args[:repeat_in].to_i.times do
        RetsQuery.continue_pulling args[:server_in]
      end
    else
      RetsQuery.perform_query args[:server_in], class: args[:class_in], query: args[:query_in]
    end
  end

  task :validate, [:server_in] => :environment do |tsk, args|
    args.with_defaults(server_in: '')
    if !args[:server_in].empty?
      server = RetsServer.find_by_name(args[:server_in])
      if server.nil?
        server = RetsServer.find(args[:server_in].to_i)
      end
    end

    if args[:server_in].nil? || args[:server_in].empty? || server.nil?
      puts "Please specify a server name like:"
      puts "   rake import:rets[SERVERNAME]]"
      puts "   rake import:rets[SERVERID]]"
      servers = RetsServer.all
      if !servers.nil? && !servers.empty?
        servers.each do |srvr|
          puts "    rake import:rets[#{srvr.name}]"
          puts "    or"
          puts "    rake import:rets[#{srvr.id}]"
        end
      else
        puts " NO SERVERS DEFINED IN rets_servers in the db"
      end
      next
    end
    RetsQuery.all.each { |rq| rq.validate_query if rq.unvalidated_rets_lines.count > 0 }
  end

end
