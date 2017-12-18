class AddUserOrderToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :user_order, :integer
  end
end
