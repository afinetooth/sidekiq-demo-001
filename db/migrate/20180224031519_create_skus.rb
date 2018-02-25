class CreateSkus < ActiveRecord::Migration[5.1]
  def change
    create_table :skus do |t|
      t.integer :style_id
      t.string :size
      t.string :color
      t.integer :price
      t.string :sku
      t.string :upc

      t.timestamps
    end
  end
end
