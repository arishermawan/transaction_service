class AddCustomerAndDriverToOrders < ActiveRecord::Migration[5.1]
  def change
    add_reference :orders, :customer, foreign_key: true
    add_reference :orders, :driver, foreign_key: true
  end
end
