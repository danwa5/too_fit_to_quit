module Converters
  class DistanceService
    include Services::BaseService
    extend Dry::Initializer

    option :value
    option :unit

    MILES_PER_METER = 0.000621371

    def call
      return nil if value.blank?

      n = case unit
        when 'meter' then value.to_f * MILES_PER_METER
        when 'mile' then value.to_f / MILES_PER_METER
        end

      sprintf('%.2f', n.round(2))
    end
  end
end
