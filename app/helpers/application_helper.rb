module ApplicationHelper

  MILES_PER_METER = 0.000621371

  def format_date(date_string)
    return 'N/A' unless date_string.present?
    year, month, day = date_string.split('-')
    date = DateTime.new(year.to_i, month.to_i, day.to_i)
    date.strftime('%A, %B %-d, %Y')
  end

  # formats 2016-07-31 14:00:00 UTC => Sun, 7/31/2016  7:00am
  def format_run_time(date_string_utc)
    Time.zone.parse(date_string_utc.to_s).strftime('%a, %-m/%-d/%Y %l:%M%P')
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
    x = if unit == 'meter'
      amount.to_f * MILES_PER_METER
    elsif unit == 'mile'
      amount.to_f / MILES_PER_METER
    end
    sprintf('%.2f', x.round(2))
  end

  def format_duration(seconds)
    f_seconds = seconds % 60
    minutes = seconds / 60
    f_minutes = minutes % 60
    hours = minutes < 60 ? '' : "#{(minutes / 60).to_s}:"
    "#{hours}#{f_minutes.to_s.rjust(2,'0')}:#{f_seconds.to_s.rjust(2,'0')}"
  end

  def convert_to_seconds(minutes)
    minutes.blank? ? nil : (minutes.to_f * 60)
  end

  def format_pace(seconds, meters)
    min_per_mile = seconds / (meters * MILES_PER_METER * 60)
    f_seconds = (min_per_mile.modulo(1) * 60).round
    "#{min_per_mile.floor.to_s}:#{f_seconds.to_s.rjust(2,'0')}"
  end
end
