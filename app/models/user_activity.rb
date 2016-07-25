class UserActivity < ActiveRecord::Base
  belongs_to :user
  belongs_to :activity, polymorphic: true

  validates :user, presence: true
  validates :uid, presence: true
end
