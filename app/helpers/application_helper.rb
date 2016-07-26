module ApplicationHelper
  
  def format_date(date_string)
    return 'N/A' unless date_string.present?
    year, month, day = date_string.split('-')
    date = DateTime.new(year.to_i, month.to_i, day.to_i)
    date.strftime('%A, %B %-d, %Y')
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

  def format_distance(meters)
    (meters * 0.00062137).round(2)
  end

  def format_duration(seconds)
    f_seconds = seconds % 60
    minutes = seconds / 60
    f_minutes = minutes % 60
    hours = minutes / 60
    "#{hours}:#{f_minutes.to_s.rjust(2,'0')}:#{f_seconds.to_s.rjust(2,'0')}"
  end
end
