require 'rails_helper'

RSpec.describe RunPresenter do
  let(:user) { create(:user) }
  let(:user_activity) { create(:user_activity, :fitbit, user: user, distance: 12345.6, start_time: '2016-07-31 14:00:00 UTC') }
  let!(:fitbit_run) { create(:activity_fitbit_run, :with_gps_data, user: user, user_activity: user_activity) }

  subject { described_class.new(user_activity) }

  it { expect(subject).to be_kind_of(SimpleDelegator) }

  describe 'MILES_PER_METER' do
    it { expect(described_class::MILES_PER_METER).to eq(0.00062137) }
  end

  describe '#formatted_distance' do
    it 'converts meters to miles' do
      expect(subject.formatted_distance).to eq(7.67)
    end
  end

  describe '#formatted_short_start_time' do
    it 'converts and formats datetime from UTC to PST' do
      expect(subject.formatted_short_start_time).to eq('Sun, 7/31/2016 7:00am')
    end
  end

  describe '#formatted_long_start_time' do
    it 'converts and formats datetime from UTC to PST' do
      expect(subject.formatted_long_start_time).to eq('Sunday, 7/31/2016 at 7:00am')
    end
  end

  describe '#final_split_distance' do
    context 'when run distance is a whole number' do
      let_override(:user_activity) { |ua| ua.distance = 1609.34 }
      it 'returns the last mile' do
        expect(subject.final_split_distance).to eq(1)
      end
    end
    context 'when run distance is fractional' do
      it 'returns the last fractional mile' do
        expect(subject.final_split_distance).to eq(0.67)
      end
    end
  end

  describe '#chart_data' do
    context 'when gps_data is present' do
      it 'returns datetime, altitude, and heart rate data' do
        expect(subject.chart_data).to be_kind_of(Array)
        expect(subject.chart_data.first.keys).to eq(%w(datetime altitude heart_rate))
      end
    end
    context 'when gps_data is nil' do
      let(:fitbit_run) { create(:activity_fitbit_run, user: user, user_activity: user_activity, gps_data: nil) }
      it 'returns an empty array' do
        expect(subject.chart_data).to eq([])
      end
    end
  end

  describe '#coordinates' do
    context 'when gps_data is present' do
      it 'returns coordinates data' do
        expect(subject.coordinates).to be_kind_of(Array)
        expect(subject.coordinates.first[0]).to match(/\d+\.\d+/)
        expect(subject.coordinates.first[1]).to match(/\d+\.\d+/)
      end
    end
    context 'when gps_data is nil' do
      let(:fitbit_run) { create(:activity_fitbit_run, user: user, user_activity: user_activity, gps_data: nil) }
      it 'returns an empty array' do
        expect(subject.coordinates).to eq([])
      end
    end
  end

  describe '#bounds' do
    context 'when gps_data is present' do
      it 'returns bounds data' do
        b = fitbit_run.gps_data['derived']['bounds']
        expect(subject.bounds).to eq([[b['west'],b['south']], [b['east'],b['north']]])
      end
    end
    context 'when gps_data is nil' do
      let(:fitbit_run) { create(:activity_fitbit_run, user: user, user_activity: user_activity, gps_data: nil) }
      it 'returns an empty array' do
        expect(subject.bounds).to eq([])
      end
    end
  end

  describe '#markers' do
    context 'when gps_data is present' do
      it 'returns markers data' do
        m = fitbit_run.gps_data['derived']['markers']
        expect(subject.markers).to eq(m)
      end
    end
    context 'when gps_data is nil' do
      let(:fitbit_run) { create(:activity_fitbit_run, user: user, user_activity: user_activity, gps_data: nil) }
      it 'returns an empty array' do
        expect(subject.markers).to eq([])
      end
    end
  end
end
