class AddRetsServerIdToRetsCollection < ActiveRecord::Migration
  def change
    add_column :rets_collections, :rets_server_id, :integer, :null => false
    add_column :rets_queries, :rets_server_id, :integer, :null => false
  end
end
