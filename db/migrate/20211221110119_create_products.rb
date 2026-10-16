class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.bigint :shopify_id
      t.string :shopify_title
      t.string :shopify_handle
      t.boolean :published, default: true

      t.references :shop, foreign_key: true

      t.timestamps
    end
  end
end
