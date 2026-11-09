class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order,   null: false, foreign_key: { on_delete: :cascade }
      t.references :product, null: false, foreign_key: true
      t.integer :quantity,   null: false
      t.decimal :unit_price, null: false, precision: 8, scale: 2
      t.timestamps
    end
    add_index :order_items, [:order_id, :product_id], unique: true
    add_check_constraint :order_items, "quantity BETWEEN 1 AND 50", name: "order_items_quantity_range"
  end
end
