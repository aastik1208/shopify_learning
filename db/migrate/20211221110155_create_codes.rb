class CreateCodes < ActiveRecord::Migration[6.0]
  def change
    create_table :codes do |t|
      t.string :name
      t.integer :usage_limit, default: 1, null: false
      t.integer :times_used, default: 0, null: false
      t.integer :products_in_order_limit, default: 1, null: false
      t.datetime :expiry_date
      t.datetime :last_used_at
      t.integer :setting_id, index: true

      t.references :shop, foreign_key: true
      t.references :prefix, foreign_key: true

      t.timestamps
    end
  end
end
