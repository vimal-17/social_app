class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post

  has_many :interactions, as: :object

  after_create :increase_post_comment_count
  after_destroy :decrease_post_comment_count

  # should be async call
  def increase_post_comment_count
    self.post.increase_comment
  end

  # should be async call
  def decrease_post_comment_count
    self.post.decrease_comment
  end

  def increase_like
    increment!(:like_count)
  end

  def increase_dislike
    increment!(:dislike_count)
  end

  def decrease_like
    decrement!(:like_count)
  end

  def decrease_dislike
    decrement!(:dislike_count)
  end
end
