json.extract! password, :id, :crypted_password, :password_salt, :created_at, :updated_at
json.url password_url(password, format: :json)
