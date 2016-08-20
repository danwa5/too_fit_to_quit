module Fitbit
  class GpsDataParser
    def initialize(gps_data, attributes)
      @gps_data = gps_data
      @attributes = attributes
    end

    def parse
      return [] if @attributes.empty?
      
      @gps_data['raw'].map do |data|
        if @attributes.count == 1
          data[@attributes.first]
        else
          h = Hash.new
          @attributes.each do |attribute|
            h[attribute] = data[attribute]
          end
          h
        end
      end
    end
  end
end
