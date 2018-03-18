module Converters
  class DurationService
    include Services::BaseService
    extend Dry::Initializer

    option :value
    option :unit

    def call
      return if value.blank?

      if unit == 'minute'
        value.to_f * 60
      elsif unit == 'second'
        f_seconds = value % 60
        minutes = value / 60
        f_minutes = minutes % 60
        hours = minutes < 60 ? '' : "#{(minutes / 60).to_s}:"
        "#{hours}#{f_minutes.to_s.rjust(2,'0')}:#{f_seconds.to_s.rjust(2,'0')}"
      end
    end
  end
end
