class Activity::FitbitRun < ActiveRecord::Base
  include Searchable

  belongs_to :user
  has_one :user_activity, as: :activity

  validates :user, presence: true
  validates :user_activity, presence: true

  scope :locations, -> { pluck(:city, :country).uniq.select { |x| x.first.present? } }

  def self.search(options = {})
    finder = joins(:user_activity).where(nil)
    finder = finder.number_within_range(:distance, options[:distance_min], options[:distance_max])
    finder = finder.number_within_range(:duration, options[:duration_min], options[:duration_max])
    finder = finder.number_within_range(:steps, options[:steps_min], options[:steps_max])
    finder = finder.date_within_range(:start_time, options[:start_date], options[:end_date], options[:time_zone])
    finder = finder.matching_contain(:city, options[:city])
    finder
  end

  def location
    return '' unless self.city.present?
    loc = String.new
    loc << self.city
    loc << ', ' + self.country if self.country.present?
    loc
  end
end
