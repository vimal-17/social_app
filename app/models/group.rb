class Group < ApplicationRecord
  belongs_to :admin, class_name: 'User', foreign_key: :admin_id

  has_many :group_users, dependent: :destroy
  has_many :users, through: :group_users

  has_many :posts

  after_create :add_admin_to_group

  def add_admin_to_group
    GroupUser.create!(group_id: self.id, user_id: self.admin_id, status: 'active')
  end
end
