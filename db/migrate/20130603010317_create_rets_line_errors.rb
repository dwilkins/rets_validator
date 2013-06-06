class CreateRetsLineErrors < ActiveRecord::Migration
  def change
    create_table :rets_line_errors do |t|
      t.integer :rets_line_id
      t.integer :rets_table_id
      t.string :error

      t.timestamps
    end
  end
end
