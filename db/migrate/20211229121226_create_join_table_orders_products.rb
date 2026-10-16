class CreateJoinTableOrdersProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :orders_products, id: false do |t|
      t.references :order, foreign_key: true
      t.references :product, foreign_key: true
    end
  end
end
