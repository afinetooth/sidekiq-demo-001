json.extract! line, :id, :order_id, :sku_id, :qty, :created_at, :updated_at
json.url line_url(line, format: :json)
