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
end
