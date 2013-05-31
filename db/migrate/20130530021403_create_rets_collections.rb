class CreateRetsCollections < ActiveRecord::Migration
  def change
    create_table :rets_collections do |t|
      t.string :collection_type, limit: 25
      t.datetime :publication_date
      t.string :version, limit: 25

      t.timestamps
    end
  end
end
