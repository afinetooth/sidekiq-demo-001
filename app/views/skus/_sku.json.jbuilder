json.extract! sku, :id, :style_id, :size, :price, :upc, :created_at, :updated_at
json.url sku_url(sku, format: :json)
