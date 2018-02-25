class CreateUnits < ActiveRecord::Migration[5.1]
  def change
    create_table :units, id: :uuid do |t|
      t.integer :sku_id
      t.string :warehouse
      t.string :bin
      t.string :status

      t.timestamps
    end
  end
end
