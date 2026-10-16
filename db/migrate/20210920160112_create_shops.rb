class CreateShops < ActiveRecord::Migration[6.0]
  def change
    create_table :shops  do |t|
      t.string :shopify_domain, null: false
      t.string :shopify_token, null: false

      t.index :shopify_domain, unique: true

      t.timestamps
    end
  end
end
