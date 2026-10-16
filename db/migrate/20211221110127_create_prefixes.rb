class CreatePrefixes < ActiveRecord::Migration[6.0]
  def change
    create_table :prefixes do |t|
      t.string :name
      t.string :custom_collection_handle

      t.references :shop, foreign_key: true

      t.timestamps
    end
  end
end
