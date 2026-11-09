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

ActiveRecord::Schema[8.1].define(version: 2026_11_09_100009) do
  create_table "addresses", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "cep", limit: 8, null: false
    t.string "street", limit: 150, null: false
    t.string "number", limit: 10, null: false
    t.string "complement", limit: 60
    t.string "neighborhood", limit: 80, null: false
    t.string "city", limit: 80, null: false
    t.string "state", limit: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", limit: 60, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "coupons", force: :cascade do |t|
    t.string "code", limit: 30, null: false
    t.string "kind", limit: 12, null: false
    t.decimal "value", precision: 8, scale: 2, null: false
    t.date "valid_until", null: false
    t.integer "usage_limit", default: 100, null: false
    t.integer "used_count", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_coupons_on_code", unique: true
    t.check_constraint "kind IN ('percentual','fixo')", name: "coupons_kind_check"
    t.check_constraint "value > 0", name: "coupons_value_positive"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "product_id", null: false
    t.integer "quantity", null: false
    t.decimal "unit_price", precision: 8, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id", "product_id"], name: "index_order_items_on_order_id_and_product_id", unique: true
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
    t.check_constraint "quantity BETWEEN 1 AND 50", name: "order_items_quantity_range"
  end

  create_table "order_status_changes", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "user_id"
    t.string "from_status", limit: 20
    t.string "to_status", limit: 20, null: false
    t.datetime "created_at", null: false
    t.index ["order_id"], name: "index_order_status_changes_on_order_id"
    t.index ["user_id"], name: "index_order_status_changes_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "address_id", null: false
    t.integer "coupon_id"
    t.string "number", limit: 20, null: false
    t.string "status", limit: 20, default: "recebido", null: false
    t.decimal "subtotal", precision: 10, scale: 2, null: false
    t.decimal "discount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "shipping", precision: 10, scale: 2, null: false
    t.decimal "total", precision: 10, scale: 2, null: false
    t.string "payment_method", limit: 10, null: false
    t.integer "installments", default: 1, null: false
    t.string "payment_code", limit: 120
    t.datetime "paid_at"
    t.date "delivery_date", null: false
    t.string "delivery_period", limit: 10, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_orders_on_address_id"
    t.index ["coupon_id"], name: "index_orders_on_coupon_id"
    t.index ["number"], name: "index_orders_on_number", unique: true
    t.index ["user_id"], name: "index_orders_on_user_id"
    t.check_constraint "payment_method IN ('cartao','pix','boleto')", name: "orders_payment_check"
    t.check_constraint "status IN ('recebido','confirmado','em_preparo','saiu_para_entrega','entregue','cancelado')", name: "orders_status_check"
  end

  create_table "products", force: :cascade do |t|
    t.integer "category_id", null: false
    t.string "name", limit: 100, null: false
    t.text "description", null: false
    t.text "ingredients", null: false
    t.string "allergens", limit: 200
    t.decimal "price", precision: 8, scale: 2, null: false
    t.integer "stock", default: 0, null: false
    t.integer "min_stock", default: 10, null: false
    t.boolean "active", default: false, null: false
    t.string "image_url", limit: 500
    t.integer "sold_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["name"], name: "index_products_on_name", unique: true
    t.check_constraint "price > 0", name: "products_price_positive"
    t.check_constraint "stock >= 0", name: "products_stock_non_negative"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "product_id", null: false
    t.integer "order_id", null: false
    t.integer "rating", null: false
    t.text "comment"
    t.boolean "approved", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id", "product_id"], name: "index_reviews_on_order_id_and_product_id", unique: true
    t.index ["order_id"], name: "index_reviews_on_order_id"
    t.index ["product_id"], name: "index_reviews_on_product_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
    t.check_constraint "rating BETWEEN 1 AND 5", name: "reviews_rating_range"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", limit: 120, null: false
    t.string "email", limit: 160, null: false
    t.string "password_digest", null: false
    t.string "cpf", limit: 11
    t.string "phone", limit: 20
    t.string "role", limit: 20, default: "cliente", null: false
    t.boolean "approved", default: true, null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_until"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cpf"], name: "index_users_on_cpf", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.check_constraint "role IN ('cliente','admin','superadmin')", name: "users_role_check"
  end

  add_foreign_key "addresses", "users", on_delete: :cascade
  add_foreign_key "order_items", "orders", on_delete: :cascade
  add_foreign_key "order_items", "products"
  add_foreign_key "order_status_changes", "orders", on_delete: :cascade
  add_foreign_key "order_status_changes", "users"
  add_foreign_key "orders", "addresses"
  add_foreign_key "orders", "coupons"
  add_foreign_key "orders", "users"
  add_foreign_key "products", "categories"
  add_foreign_key "reviews", "orders"
  add_foreign_key "reviews", "products"
  add_foreign_key "reviews", "users"
end
