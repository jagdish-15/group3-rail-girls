json.extract! event, :id, :title, :description, :category, :venue, :starts_at, :duration, :mode, :image_url, :price, :created_at, :updated_at
json.url event_url(event, format: :json)
