json.extract! password, :id, :site, :username, :password, :created_at, :updated_at
json.url password_url(password, format: :json)
