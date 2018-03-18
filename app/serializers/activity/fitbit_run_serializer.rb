class Activity::FitbitRunSerializer < ActiveModel::Serializer
  has_one :user_activity

  attributes :id, :steps, :location
end
