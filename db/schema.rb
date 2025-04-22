# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_04_18_121708) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bill_orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "status", default: 0
    t.string "meter_number"
    t.decimal "amount"
    t.decimal "total_amount"
    t.integer "meter_type", default: 0
    t.string "phone"
    t.string "biller"
    t.string "service_type"
    t.integer "payment_type", default: 0
    t.string "email"
    t.string "tariff_class"
    t.string "name"
    t.uuid "order_detail_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address"
    t.string "units"
    t.string "transaction_id"
    t.string "token"
    t.uuid "user_id"
    t.decimal "usd_amount"
    t.integer "payment_method", default: 0
    t.decimal "service_charge", default: "0.0"
    t.string "description"
    t.index ["order_detail_id"], name: "index_bill_orders_on_order_detail_id"
    t.index ["user_id"], name: "index_bill_orders_on_user_id"
  end

  create_table "card_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "reveal", default: false
    t.uuid "order_item_id", null: false
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_item_id"], name: "index_card_tokens_on_order_item_id"
  end

  create_table "currencies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "currency_rates"
    t.string "rate_time_stamp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "exchange_rates"
  end

  create_table "electric_bill_orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "meter_number"
    t.string "meter_type"
    t.string "meter_address"
    t.string "customer_name"
    t.string "email"
    t.string "request_id"
    t.string "phone"
    t.string "serviceID"
    t.uuid "order_detail_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.string "transaction_id"
    t.decimal "amount"
    t.string "token"
    t.decimal "total_amount"
    t.index ["order_detail_id"], name: "index_electric_bill_orders_on_order_detail_id"
  end

  create_table "gift_cards", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "provider"
    t.string "provision"
    t.decimal "value"
    t.text "header_info"
    t.text "description"
    t.integer "rating"
    t.text "notice_info"
    t.text "alert_info"
    t.decimal "value_max"
    t.decimal "value_min"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_details", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "total_amount"
    t.integer "status", default: 0
    t.integer "payment_method", default: 0
    t.boolean "viewed", default: false
    t.decimal "net_total"
    t.uuid "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order_type", default: 0
    t.text "extra_info"
    t.index ["user_id"], name: "index_order_details_on_user_id"
  end

  create_table "order_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "quantity", default: 1
    t.decimal "amount"
    t.uuid "product_id", null: false
    t.uuid "order_detail_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "provision_id"
    t.index ["order_detail_id"], name: "index_order_items_on_order_detail_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
    t.index ["provision_id"], name: "index_order_items_on_provision_id"
  end

  create_table "products", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "featured", default: false
    t.string "extra_info"
    t.string "provider"
    t.string "image"
    t.string "provision"
    t.decimal "min_value"
    t.decimal "max_value"
    t.text "header_info"
    t.text "description"
    t.integer "rate", default: 5
    t.integer "category", default: 0
    t.integer "currency", default: 0
    t.text "info"
    t.text "attention"
    t.text "notice_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "provisions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "min_value"
    t.string "max_value"
    t.integer "provision_value_type"
    t.uuid "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "value"
    t.text "description"
    t.integer "currency", default: 0
    t.text "info"
    t.text "notice"
    t.decimal "value_range", default: [], array: true
    t.string "service_type"
    t.index ["product_id"], name: "index_provisions_on_product_id"
  end

  create_table "transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "status", default: 0
    t.decimal "amount"
    t.string "address"
    t.integer "transaction_type", default: 0
    t.uuid "wallet_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "coin_type", default: 0
    t.string "bank"
    t.decimal "bonus", default: "0.0"
    t.index ["wallet_id"], name: "index_transactions_on_wallet_id"
  end

  create_table "user_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.uuid "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_profiles_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti", null: false
    t.string "role", default: "client"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wallets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "wallet_type", default: 0
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bill_orders", "order_details"
  add_foreign_key "bill_orders", "users"
  add_foreign_key "card_tokens", "order_items"
  add_foreign_key "electric_bill_orders", "order_details"
  add_foreign_key "order_details", "users"
  add_foreign_key "order_items", "order_details"
  add_foreign_key "order_items", "products"
  add_foreign_key "order_items", "provisions"
  add_foreign_key "provisions", "products"
  add_foreign_key "transactions", "wallets"
  add_foreign_key "user_profiles", "users"
  add_foreign_key "wallets", "users"
end
