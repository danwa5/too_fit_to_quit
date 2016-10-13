module Searchable
  extend ActiveSupport::Concern

  included do
    scope :number_within_range, ->(column, low_value, high_value) do
      return where("#{column} >= ? AND #{column} <= ?", low_value, high_value) if !low_value.blank? && !high_value.blank?
      return where("#{column} >= ?", low_value) if !low_value.blank?
      return where("#{column} <= ?", high_value) if !high_value.blank?
      return where(nil)
    end
  end
end
