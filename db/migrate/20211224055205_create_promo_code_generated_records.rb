class CreatePromoCodeGeneratedRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :promo_code_generated_records do |t|
      t.references :shop, foreign_key: true
      t.string :prefix
      t.integer :count
      t.integer :status

      t.timestamps
    end
  end
end
