class Activity::StravaRun < ActiveRecord::Base
  belongs_to :user
  has_one :user_activity, as: :activity

  validates :user, presence: true
  validates :user_activity, presence: true

  def start_coordinate
    [start_longitude.to_f, start_latitude.to_f] if start_latitude.present? && start_longitude.present?
  end

  def location
    l = ''
    l << "in #{city}" if city.present?
    l << ", #{state_province}" if state_province.present?
    l
  end
end
