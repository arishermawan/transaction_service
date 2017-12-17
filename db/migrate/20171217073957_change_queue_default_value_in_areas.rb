class ChangeQueueDefaultValueInAreas < ActiveRecord::Migration[5.1]
  def change
      change_column_default :areas, :queue, "[]"
  end
end
