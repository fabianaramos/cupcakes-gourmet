class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.references :category, null: false, foreign_key: true
      t.string  :name,        null: false, limit: 100
      t.text    :description, null: false
      t.text    :ingredients, null: false
      t.string  :allergens,   limit: 200
      t.decimal :price,       null: false, precision: 8, scale: 2
      t.integer :stock,       null: false, default: 0
      t.integer :min_stock,   null: false, default: 10
      t.boolean :active,      null: false, default: false
      t.string  :image_url,   limit: 500
      t.integer :sold_count,  null: false, default: 0
      t.timestamps
    end
    add_index :products, :name, unique: true
    add_check_constraint :products, "price > 0", name: "products_price_positive"
    add_check_constraint :products, "stock >= 0", name: "products_stock_non_negative"
  end
end
