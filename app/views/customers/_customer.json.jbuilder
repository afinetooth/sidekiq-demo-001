json.extract! customer, :id, :name, :email, :address_shipping_street_1, :address_shipping_street_2, :address_shipping_city, :address_shipping_state, :address_shipping_zip, :address_shipping_country, :address_billing_street_1, :address_billing_street_2, :address_billing_city, :address_billing_state, :address_billing_zip, :address_billing_country, :created_at, :updated_at
json.url customer_url(customer, format: :json)