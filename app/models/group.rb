class Group < ApplicationRecord
  belongs_to :admin, class_name: 'User', foreign_key: :admin_id

  has_many :group_users, dependent: :destroy
  has_many :users, through: :group_users

  has_many :posts
end
