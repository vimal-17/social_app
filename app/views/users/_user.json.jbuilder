json.extract! user, :id, :name, :username, :email, :mobile_number, :profile_picture, :bio, :password, :status, :created_at, :updated_at, :created_at, :updated_at
json.url user_url(user, format: :json)
