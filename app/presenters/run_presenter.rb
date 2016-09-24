class RunPresenter < SimpleDelegator
  MILES_PER_METER = 0.00062137

  def run
    __getobj__
  end

  def formatted_distance
    (run.distance * MILES_PER_METER).round(2)
  end

  def formatted_short_start_time(time_zone='Pacific Time (US & Canada)')
    Time.parse(run.start_time.to_s).in_time_zone(time_zone).strftime('%a, %-m/%-d/%Y%l:%M%P')
  end

  def formatted_long_start_time(time_zone='Pacific Time (US & Canada)')
    Time.parse(run.start_time.to_s).in_time_zone(time_zone).strftime('%A, %-m/%-d/%Y at%l:%M%P')
  end

  def final_split_distance
    formatted_distance.modulo(1) == 0 ? formatted_distance.to_i : formatted_distance.modulo(1).round(2)
  end
end
