class UserActivitySerializer < ActiveModel::Serializer
  belongs_to :fitbit_run

  attributes :id, :distance, :duration, :pace, :start_time

  def distance
    Converters::DistanceService.call(value: object.distance, unit: 'meter')
  end

  def duration
    Converters::DurationService.call(value: object.duration, unit: 'second')
  end

  def pace
    Converters::PaceService.call(seconds: object.duration, meters: object.distance)
  end

  def start_time
    Time.parse(object.start_time.to_s).in_time_zone("Pacific Time (US & Canada)").strftime('%a, %-m/%-d/%Y %l:%M%P')
  end
end
