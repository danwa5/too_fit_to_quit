class RunPresenter < SimpleDelegator
  MILES_PER_METER = 0.00062137

  def run
    __getobj__
  end

  def formatted_distance
    (run.distance * MILES_PER_METER).round(2)
  end

  # formats 2016-07-31 14:00:00 UTC => Sun, 7/31/2016 7:00am
  def formatted_short_start_time(time_zone='Pacific Time (US & Canada)')
    Time.parse(run.start_time.to_s).in_time_zone(time_zone).strftime('%a, %-m/%-d/%Y%l:%M%P')
  end

  # formats 2016-07-31 14:00:00 UTC => Sunday, 7/31/2016 at 7:00am
  def formatted_long_start_time(time_zone='Pacific Time (US & Canada)')
    Time.parse(run.start_time.to_s).in_time_zone(time_zone).strftime('%A, %-m/%-d/%Y at%l:%M%P')
  end

  def final_split_distance
    formatted_distance.modulo(1) == 0 ? formatted_distance.to_i : formatted_distance.modulo(1).round(2)
  end

  def chart_data
    if activity.gps_data.present?
      Fitbit::GpsDataParser.new(activity.gps_data, %w(datetime altitude heart_rate)).parse
    else
      []
    end
  end

  def coordinates
    if activity.gps_data.present?
      Fitbit::GpsDataParser.new(activity.gps_data, %w(coordinate)).parse
    else
      []
    end
  end

  def bounds
    if activity.gps_data.present?
      bounds = activity.gps_data['derived']['bounds']
      [[bounds['west'],bounds['south']], [bounds['east'],bounds['north']]]
    else
      []
    end
  end

  def markers
    if activity.gps_data.present?
      activity.gps_data['derived']['markers']
    else
      []
    end
  end
end
