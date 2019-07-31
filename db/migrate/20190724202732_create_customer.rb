class CreateCustomer < ActiveRecord::Migration[5.0]
  def change
    create_table :customers do |t|
      t.string :email
      t.string :lastName
      t.string :firstName
      t.decimal :lastOrder, precision: 20, scale: 2, default: 0
      t.decimal :lastOrder2, precision: 20, scale: 2, default: 0
      t.decimal :lastOrder3, precision: 20, scale: 2, default: 0
      t.decimal :award, precision: 20, scale: 2, default: 0
    end
  end
end
