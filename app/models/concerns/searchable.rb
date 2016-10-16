module Searchable
  extend ActiveSupport::Concern

  included do
    scope :number_within_range, ->(column, low_value, high_value) do
      return where("#{column} >= ? AND #{column} <= ?", low_value, high_value) if !low_value.blank? && !high_value.blank?
      return where("#{column} >= ?", low_value) if !low_value.blank?
      return where("#{column} <= ?", high_value) if !high_value.blank?
      return where(nil)
    end

    scope :date_within_range, ->(column, start_date, end_date, time_zone='UTC') do
      column_time_zone = "#{column}::timestamp at time zone 'UTC' at time zone '#{time_zone}'"
      return where("#{column_time_zone} >= DATE(?) AND #{column_time_zone} <= DATE(?) + INTERVAL '1 DAY'", start_date, end_date) if !start_date.blank? && !end_date.blank?
      return where("#{column_time_zone} >= DATE(?)", start_date) if !start_date.blank?
      return where("#{column_time_zone} <= DATE(?) + INTERVAL '1 DAY'", end_date) if !end_date.blank?
      return where(nil)
    end
  end

  class_methods do
  end
end
