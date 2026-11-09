class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string  :name,            null: false, limit: 120
      t.string  :email,           null: false, limit: 160
      t.string  :password_digest, null: false
      t.string  :cpf,             limit: 11
      t.string  :phone,           limit: 20
      t.string  :role,            null: false, default: "cliente", limit: 20 # cliente | admin | superadmin
      t.boolean :approved,        null: false, default: true
      t.integer :failed_attempts, null: false, default: 0
      t.datetime :locked_until
      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :cpf, unique: true
    add_check_constraint :users, "role IN ('cliente','admin','superadmin')", name: "users_role_check"
  end
end
