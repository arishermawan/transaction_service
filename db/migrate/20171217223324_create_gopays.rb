class CreateGopays < ActiveRecord::Migration[5.1]
  def change
    create_table :gopays do |t|
      t.decimal :credit
      t.integer :user_id
      t.integer :user_type

      t.timestamps
    end
  end
end
