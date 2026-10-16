class AddColumnsToShop < ActiveRecord::Migration[6.0]
  def change
    change_table :shops do |t|
      t.string :name
      t.string :shopify_email
      t.string :admin_emails
      t.integer :usage_limit_update_amount, default: 10, null: false
      t.integer :usage_limit_update_amount_for_exhausted, default: 5, null: false
      t.boolean :automate_usage_limit_update, default: false, null: false
      t.boolean :show_inventory_count, default: false, null: false
      t.boolean :auto_fulfil_digital_order, default: false
    end
  end
end
