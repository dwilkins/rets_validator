class CreateRetsServers < ActiveRecord::Migration
  def change
    create_table :rets_servers do |t|
      t.string :name
      t.string :username
      t.string :password
      t.string :login_url
      t.string :contact_info
      t.string :counties
      t.string :state

      t.timestamps
    end
  end
end
