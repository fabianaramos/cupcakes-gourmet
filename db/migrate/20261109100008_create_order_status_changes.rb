class CreateOrderStatusChanges < ActiveRecord::Migration[8.1]
  def change
    create_table :order_status_changes do |t|
      t.references :order, null: false, foreign_key: { on_delete: :cascade }
      t.references :user,  foreign_key: true # quem alterou
      t.string :from_status, limit: 20
      t.string :to_status,   null: false, limit: 20
      t.datetime :created_at, null: false
    end
  end
end
