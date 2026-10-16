class CreateJoinTablePrefixesProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :prefixes_products, id: false do |t|
      t.references :prefix, foreign_key: true
      t.references :product, foreign_key: true
    end
  end
end
