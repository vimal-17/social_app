class User < ApplicationRecord
  has_many :posts, class_name: 'Post'

  has_many :comments, class_name: 'Comment'

  has_many :interactions

  has_many :admin_groups, class_name: 'Group', foreign_key: :admin_id

  has_many :group_users, class_name: 'GroupUser'
  has_many :groups, through: :group_users

  validates :email, presence: true
  validates :mobile_number, presence: true
  validates :email, uniqueness: { scope: :mobile_number, message: "and mobile number combination must be unique" }
end
