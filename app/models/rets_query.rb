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
  attr_accessible :options


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
    error = []
    if !opts[:username]
      error = [":username option missing"]
    end
    if !opts[:password]
      error << ":password option missing"
    end
    if !opts[:query]
      error << ":query option missing"
    end
    if !opts[:url]
      error << ":url option missing"
    end
    if !error.empty?
      raise ArgumentError, error.join(','), caller
    end

    opts = query_defaults.merge(opts)

    if File.exists? 'rets.yml'
      metadata = File.open('rets.yml'){ |rets_data| YAML.load rets_data }
    else
      puts "Couldn't open rets.yml"
      return
    end
    opts[:fields] ||= metadata['Table-1-Property'][:system_names].collect { |k,v| k if k != '12' && k != "2906" && !k.empty? }
    puts opts[:fields].class
    stored_options = {}
    stored_options.merge!(opts)
    stored_options[:password] = nil
    stored_options[:password_hash] = Digest::SHA512.base64digest opts[:password]

    this_query = RetsQuery.create options: stored_options.to_yaml
    client = RETS::Client.login opts
    rows_returned = 0
    status = 0
    client.search(:search_type => opts[:search_type],
                  format: opts[:format],
                  class: opts[:class],
                  query: opts[:query],
#                  count_mode: opts[:count_mode],
                  select: opts[:fields],
                  standard_names: opts[:standard_names],
                  limit: opts[:limit]) do |data|
      if data.keys.length < 2 && data['sysid'] && !data['sysid'].empty?
        status = -1
      end
      line = RetsLine.create rets_query_id: this_query.id, rets_type: "Table", rets_sysid: data['sysid'], source: data.to_yaml, status: status
      rows_returned += 1
    end
    this_query.error_code = client.rets_data[:code]
    this_query.error_message = client.rets_data[:text]
    this_query.rows_returned = rows_returned
    this_query.save
    this_query
  end

end
