class AddStatusToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :status, :integer
    change_column_default :orders, :status, 0
  end
end
