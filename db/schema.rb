# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_12_29_121226) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "codes", force: :cascade do |t|
    t.string "name"
    t.integer "usage_limit", default: 1, null: false
    t.integer "times_used", default: 0, null: false
    t.integer "products_in_order_limit", default: 1, null: false
    t.datetime "expiry_date"
    t.datetime "last_used_at"
    t.integer "setting_id"
    t.bigint "shop_id"
    t.bigint "prefix_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["prefix_id"], name: "index_codes_on_prefix_id"
    t.index ["setting_id"], name: "index_codes_on_setting_id"
    t.index ["shop_id"], name: "index_codes_on_shop_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "shopify_id"
    t.string "shopify_name"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "address1"
    t.string "address2"
    t.string "title"
    t.string "company"
    t.string "phone"
    t.string "city"
    t.string "state_name"
    t.integer "state_id"
    t.integer "country_id"
    t.string "zip"
    t.string "variant_ids", default: [], array: true
    t.string "expiration_token"
    t.jsonb "cart_attributes", default: {}
    t.datetime "redacted_at"
    t.bigint "shop_id"
    t.bigint "code_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code_id"], name: "index_orders_on_code_id"
    t.index ["country_id"], name: "index_orders_on_country_id"
    t.index ["expiration_token"], name: "index_orders_on_expiration_token", unique: true
    t.index ["shop_id"], name: "index_orders_on_shop_id"
    t.index ["state_id"], name: "index_orders_on_state_id"
  end

  create_table "orders_products", id: false, force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "product_id"
    t.index ["order_id"], name: "index_orders_products_on_order_id"
    t.index ["product_id"], name: "index_orders_products_on_product_id"
  end

  create_table "prefixes", force: :cascade do |t|
    t.string "name"
    t.string "custom_collection_handle"
    t.bigint "shop_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["shop_id"], name: "index_prefixes_on_shop_id"
  end

  create_table "prefixes_products", id: false, force: :cascade do |t|
    t.bigint "prefix_id"
    t.bigint "product_id"
    t.index ["prefix_id"], name: "index_prefixes_products_on_prefix_id"
    t.index ["product_id"], name: "index_prefixes_products_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "shopify_id"
    t.string "shopify_title"
    t.string "shopify_handle"
    t.boolean "published", default: true
    t.bigint "shop_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["shop_id"], name: "index_products_on_shop_id"
  end

  create_table "promo_code_generated_records", force: :cascade do |t|
    t.bigint "shop_id"
    t.string "prefix"
    t.integer "count"
    t.integer "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["shop_id"], name: "index_promo_code_generated_records_on_shop_id"
  end

  create_table "settings", force: :cascade do |t|
    t.boolean "has_free_domestic_shipping"
    t.boolean "has_free_international_shipping"
    t.boolean "allow_domestic_shipping"
    t.boolean "allow_international_shipping"
    t.bigint "shop_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["shop_id"], name: "index_settings_on_shop_id"
  end

  create_table "shops", force: :cascade do |t|
    t.string "shopify_domain", null: false
    t.string "shopify_token", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "access_scopes"
    t.string "name"
    t.string "shopify_email"
    t.string "admin_emails"
    t.integer "usage_limit_update_amount", default: 10, null: false
    t.integer "usage_limit_update_amount_for_exhausted", default: 5, null: false
    t.boolean "automate_usage_limit_update", default: false, null: false
    t.boolean "show_inventory_count", default: false, null: false
    t.boolean "auto_fulfil_digital_order", default: false
    t.index ["shopify_domain"], name: "index_shops_on_shopify_domain", unique: true
  end

  create_table "states", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.bigint "country_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["country_id"], name: "index_states_on_country_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "codes", "prefixes"
  add_foreign_key "codes", "shops"
  add_foreign_key "orders", "codes"
  add_foreign_key "orders", "shops"
  add_foreign_key "orders_products", "orders"
  add_foreign_key "orders_products", "products"
  add_foreign_key "prefixes", "shops"
  add_foreign_key "prefixes_products", "prefixes"
  add_foreign_key "prefixes_products", "products"
  add_foreign_key "products", "shops"
  add_foreign_key "promo_code_generated_records", "shops"
  add_foreign_key "settings", "shops"
end
