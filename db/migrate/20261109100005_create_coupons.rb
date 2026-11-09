class CreateCoupons < ActiveRecord::Migration[8.1]
  def change
    create_table :coupons do |t|
      t.string  :code,        null: false, limit: 30
      t.string  :kind,        null: false, limit: 12 # percentual | fixo
      t.decimal :value,       null: false, precision: 8, scale: 2
      t.date    :valid_until, null: false
      t.integer :usage_limit, null: false, default: 100
      t.integer :used_count,  null: false, default: 0
      t.boolean :active,      null: false, default: true
      t.timestamps
    end
    add_index :coupons, :code, unique: true
    add_check_constraint :coupons, "kind IN ('percentual','fixo')", name: "coupons_kind_check"
    add_check_constraint :coupons, "value > 0", name: "coupons_value_positive"
  end
end
