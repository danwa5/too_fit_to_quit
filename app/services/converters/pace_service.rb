module Converters
  class PaceService
    include Services::BaseService
    extend Dry::Initializer

    option :seconds
    option :meters

    MILES_PER_METER = 0.000621371

    def call
      min_per_mile = seconds.to_f / (meters.to_f * MILES_PER_METER * 60)
      f_seconds = (min_per_mile.modulo(1) * 60).round
      "#{min_per_mile.floor.to_s}:#{f_seconds.to_s.rjust(2,'0')}"
    end
  end
end
