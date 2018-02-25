class CreateStyles < ActiveRecord::Migration[5.1]
  def change
    create_table :styles do |t|
      t.string :name
      t.string :description
      t.integer :price

      t.timestamps
    end
  end
end
