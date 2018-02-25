class CreateLines < ActiveRecord::Migration[5.1]
  def change
    create_table :lines do |t|
      t.integer :order_id
      t.integer :sku_id
      t.integer :qty

      t.timestamps
    end
  end
end
