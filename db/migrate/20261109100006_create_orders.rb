class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :user,    null: false, foreign_key: true
      t.references :address, null: false, foreign_key: true
      t.references :coupon,  foreign_key: true
      t.string  :number,          null: false, limit: 20
      t.string  :status,          null: false, default: "recebido", limit: 20
      t.decimal :subtotal,        null: false, precision: 10, scale: 2
      t.decimal :discount,        null: false, precision: 10, scale: 2, default: 0
      t.decimal :shipping,        null: false, precision: 10, scale: 2
      t.decimal :total,           null: false, precision: 10, scale: 2
      t.string  :payment_method,  null: false, limit: 10 # cartao | pix | boleto
      t.integer :installments,    null: false, default: 1
      t.string  :payment_code,    limit: 120
      t.datetime :paid_at
      t.date    :delivery_date,   null: false
      t.string  :delivery_period, null: false, limit: 10 # manha | tarde | noite
      t.timestamps
    end
    add_index :orders, :number, unique: true
    add_check_constraint :orders, "status IN ('recebido','confirmado','em_preparo','saiu_para_entrega','entregue','cancelado')", name: "orders_status_check"
    add_check_constraint :orders, "payment_method IN ('cartao','pix','boleto')", name: "orders_payment_check"
  end
end
