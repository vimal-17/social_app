json.extract! interaction, :id, :object_id, :object_type, :user_id, :is_like, :status, :created_at, :updated_at
json.url interaction_url(interaction, format: :json)
