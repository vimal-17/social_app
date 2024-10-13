json.extract! comment, :id, :post_id, :user_id, :body, :status, :like_count, :dislike_count, :created_at, :updated_at
json.url comment_url(comment, format: :json)
