class Interaction < ApplicationRecord
  belongs_to :object, polymorphic: true, optional: false # Can be a Post or a Comment (Polymorphic)
  belongs_to :user

  # Validate the existence of the associated object (Post or Comment)
  validate :object_must_exist

  after_create :increment_object_counters
  after_destroy :decrement_object_counters

  after_update :sync_object_counters, if: :saved_change_to_is_like?

  # Custom validation to check if the object exists
  def object_must_exist
    if object_type == 'Post'
      errors.add(:object, "Post does not exist") unless Post.exists?(object_id)
    elsif object_type == 'Comment'
      errors.add(:object, "Comment does not exist") unless Comment.exists?(object_id)
    else
      errors.add(:object, "Invalid object type")
    end
  end

  # should be async call
  def increment_object_counters
    self.is_like ? object.increase_like : object.increase_dislike
  end

  # should be async call
  def decrement_object_counters
    self.is_like ? object.decrease_like : object.decrease_dislike
  end

  # should be async call
  def sync_object_counters
    if is_like_previously_was && !is_like # Changed from like to dislike
      object.decrease_like
      object.increase_dislike
    elsif !is_like_previously_was && is_like # Changed from dislike to like
      object.increase_like
      object.decrease_dislike
    end
  end
end
