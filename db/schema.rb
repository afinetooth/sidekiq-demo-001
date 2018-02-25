# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180225051551) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"
  enable_extension "pgcrypto"

  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "address_shipping_street_1"
    t.string "address_shipping_street_2"
    t.string "address_shipping_city"
    t.string "address_shipping_state"
    t.string "address_shipping_zip"
    t.string "address_shipping_country"
    t.string "address_billing_street_1"
    t.string "address_billing_street_2"
    t.string "address_billing_city"
    t.string "address_billing_state"
    t.string "address_billing_zip"
    t.string "address_billing_country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lines", force: :cascade do |t|
    t.integer "order_id"
    t.integer "sku_id"
    t.integer "qty"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.integer "customer_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "skus", force: :cascade do |t|
    t.integer "style_id"
    t.string "size"
    t.string "color"
    t.integer "price"
    t.string "sku"
    t.string "upc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "styles", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "units", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "sku_id"
    t.string "warehouse"
    t.string "bin"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
