class CreateCustomers < ActiveRecord::Migration[5.1]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :email
      t.string :address_shipping_street_1
      t.string :address_shipping_street_2
      t.string :address_shipping_city
      t.string :address_shipping_state
      t.string :address_shipping_zip
      t.string :address_shipping_country
      t.string :address_billing_street_1
      t.string :address_billing_street_2
      t.string :address_billing_city
      t.string :address_billing_state
      t.string :address_billing_zip
      t.string :address_billing_country

      t.timestamps
    end
  end
end
