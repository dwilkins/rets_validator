class CreateRetsQueries < ActiveRecord::Migration
  def change
    create_table :rets_queries do |t|
      t.integer :rows_returned
      t.integer :error_code
      t.string :error_message,limit: 1000
      t.string :options, limit: 3000
      t.timestamps
    end
  end
end
