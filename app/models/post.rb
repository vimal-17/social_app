class Post < ApplicationRecord
  belongs_to :user

  belongs_to :group

  has_many :interactions, as: :object

  has_many :comments

  before_create :set_default_counters

  def set_default_counters
    self.like_count = 0
    self.dislike_count = 0
    self.comment_count = 0
  end

  # To sync like / dislike / comment count from callbacks
  def increase_like
    increment!(:like_count)
  end

  def increase_dislike
    increment!(:dislike_count)
  end

  def increase_comment
    increment!(:comment_count)
  end

  def decrease_like
    decrement!(:like_count)
  end

  def decrease_dislike
    decrement!(:dislike_count)
  end

  def decrease_comment
    decrement!(:comment_count)
  end
end
