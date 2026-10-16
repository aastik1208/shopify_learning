class CreateSettings < ActiveRecord::Migration[6.0]
  def change
    create_table :settings do |t|
      t.boolean :has_free_domestic_shipping
      t.boolean :has_free_international_shipping
      t.boolean :allow_domestic_shipping
      t.boolean :allow_international_shipping

      t.references :shop, foreign_key: true

      t.timestamps
    end
  end
end
