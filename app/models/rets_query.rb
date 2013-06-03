class Hash
  def to_yaml_style
    :inline
  end
end
class Array
  def to_yaml_style
    :inline
  end
end


class RetsQuery < ActiveRecord::Base
  attr_accessible :rows_returned,:error_code, :error_message
  attr_accessible :options, :rets_server_id
  has_many :rets_lines, inverse_of: :rets_query


  def self.continue_pulling server, new_options = {}
    unless server.is_a? RetsServer
      server_in = server
      server = RetsServer.find_by_name(server_in)
      if server.nil?
        server = RetsServer.find(server_in.to_i)
      end
      if server.nil?
        puts "Could not find server #{opts[:server]}"
        return nil
      end
    end

    last_line = RetsLine.where(status: -1).order(:rets_sysid).last
    last_query = RetsQuery.order(:id).last
    options = last_query.options
    options = YAML.load(last_query.options)
    options[:server] = server
    options[:limit] ||= 1000
    options[:query] =~ /([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\+[0-9]{2}:[0-9]{2}|))-([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\+[0-9]{2}:[0-9]{2}|))/
    start_range = DateTime.parse($1)
    end_range = DateTime.parse($3)
    if end_range.second > 0
      new_start_range = end_range.advance(seconds: 1)
    elsif end_range.minute > 0
      new_start_range = end_range.advance(minutes: 1)
    elsif end_range.hour > 0
      new_start_range = end_range.advance(hours: 1)
    else
      new_start_range = end_range
    end
    new_end_range = new_start_range + (end_range - start_range)
    options[:password] = server.password
    options.merge!(new_options)
    options[:query][/([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\+[0-9]{2}:[0-9]{2}|))-([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\+[0-9]{2}:[0-9]{2}|))/] = "#{new_start_range}-#{new_end_range}"
    print "Query = " + options[:query]
    start_time = DateTime.now
    print " Rows: " + RetsQuery.perform_query(options).rows_returned.to_s
    end_time = DateTime.now
    puts " - " + (end_time.to_i - start_time.to_i).to_s + " Seconds elapsed"
  end


  def self.login
  end



#  def self.perform_query username, password, query, fields, url
  def self.query_defaults
    {
      class: '11',
      search_type: 'Property',
      count_mode: nil,
      select: nil,
      query: nil,
      offset: 0,
      standard_names: false,
      format: "COMPACT_DECODED",
      restricted: nil,
      limit: 1
    }
  end


  def self.perform_query opts = {}
    ActiveRecord::Base.logger.level = 1
    error = []
    if !opts[:server]
      error = [":server option missing"]
    end
    if !opts[:query]
      error << ":query option missing"
    end
    if !error.empty?
      raise ArgumentError, error.join(','), caller
    end

    unless opts[:server].is_a? RetsServer
      server = RetsServer.find_by_name(opts[:server])
      if server.nil?
        server = RetsServer.find(args[:server_in].to_i)
      end
      if server.nil?
        puts "Could not find server #{opts[:server]}"
        return nil
      end
    else
      server = opts[:server]
      opts[:server] = server.name
    end

    opts[:username] = server.username
    opts[:password] = server.password
    opts[:url] = server.login_url
    opts = query_defaults.merge(opts)
    @@client ||= RETS::Client.login opts

    stored_options = {password_hash: Digest::SHA512.base64digest(opts[:password])}
    c = RetsClass.find_by_class_name(opts[:class])
    opts[:select] ||= c.rets_tables.collect { |t| t.system_name if t.system_name != '12' && t.system_name != "2906" && !t.system_name.empty? }
    stored_options.merge!(opts)

    this_query = RetsQuery.create options: stored_options.to_yaml, rets_server_id: server.id


    stored_options[:password] = nil


    rows_returned = 0
    status = 0
    is_index_only = nil
    @@client.search(:search_type => opts[:search_type],
                    format: opts[:format],
                    class: opts[:class],
                    query: opts[:query],
                    count_mode: opts[:count_mode],
                    select: opts[:select],
                    standard_names: opts[:standard_names],
                    limit: opts[:limit]) do |data|
      #
      # if we pulled *only* index columns (in_key_index), then we'll set the status
      # on the row to -1, meaning we need to come back and fetch and update this row later
      #
      if is_index_only.nil?
        is_index_only = true
        RetsTable.for_class('1').where(system_name: opts[:select]).each do |t|
          if !t.in_key_index
            is_index_only = false
            status = -1
            break
          end
        end
      end
      begin
        line = RetsLine.new rets_query_id: this_query.id, rets_type: "Table", rets_sysid: data['sysid'], source: data.to_yaml, status: status
        if line.save
          rows_returned += 1
        end
      rescue Exception => e
        puts e.message
      end
    end
    this_query.error_code = @@client.rets_data[:code]
    this_query.error_message = @@client.rets_data[:text]
    this_query.rows_returned = rows_returned
    this_query.save
    this_query
  end

end
