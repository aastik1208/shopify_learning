class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.bigint :shopify_id
      t.string :shopify_name
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :address1
      t.string :address2
      t.string :title
      t.string :company
      t.string :phone
      t.string :city
      t.string :state_name
      t.integer :state_id, index: true
      t.integer :country_id, index: true
      t.string :zip
      t.string :variant_ids, array: true, default: []
      t.string :expiration_token
      t.jsonb :cart_attributes, default: {}
      t.datetime :redacted_at

      t.index :expiration_token, unique: true

      t.references :shop, foreign_key: true
      t.references :code, foreign_key: true

      t.timestamps
    end
  end
end
