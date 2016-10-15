module ApplicationHelper

  MILES_PER_METER = 0.000621371

  def format_date(date_string)
    return 'N/A' unless date_string.present?
    year, month, day = date_string.split('-')
    date = DateTime.new(year.to_i, month.to_i, day.to_i)
    date.strftime('%A, %B %-d, %Y')
  end

  # formats 2016-07-31 14:00:00 UTC => Sun, 7/31/2016  7:00am
  def format_run_time(date_string_utc, time_zone="Pacific Time (US & Canada)")
    Time.parse(date_string_utc.to_s).in_time_zone(time_zone).strftime('%a, %-m/%-d/%Y %l:%M%P')
  end

  def fitbit_periods
    [
      ['1 day', '1d'],
      ['1 week', '1w'],
      ['1 month', '1m'],
      ['3 month', '3m'],
      ['6 month', '6m'],
      ['1 year', '1y']
    ]
  end

  def format_distance(amount, unit='meter')
    return nil if amount.blank?
    if unit == 'meter'
      (amount.to_f * MILES_PER_METER).round(2)
    elsif unit == 'mile'
      (amount.to_f / MILES_PER_METER).round(2)
    end
  end

  def format_duration(seconds)
    f_seconds = seconds % 60
    minutes = seconds / 60
    f_minutes = minutes % 60
    hours = minutes < 60 ? '' : "#{(minutes / 60).to_s}:"
    "#{hours}#{f_minutes.to_s.rjust(2,'0')}:#{f_seconds.to_s.rjust(2,'0')}"
  end

  def format_pace(seconds, meters)
    min_per_mile = seconds / (meters * MILES_PER_METER * 60)
    f_seconds = (min_per_mile.modulo(1) * 60).round
    "#{min_per_mile.floor.to_s}:#{f_seconds.to_s.rjust(2,'0')}"
  end
end
