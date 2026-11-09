class CreateAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :cep,          null: false, limit: 8
      t.string :street,       null: false, limit: 150
      t.string :number,       null: false, limit: 10
      t.string :complement,   limit: 60
      t.string :neighborhood, null: false, limit: 80
      t.string :city,         null: false, limit: 80
      t.string :state,        null: false, limit: 2
      t.timestamps
    end
  end
end
