FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password 'abc123'
    password_confirmation 'abc123'

    after(:create) do |user|
      create(:identity, :fitbit, user: user)
      create(:identity, :strava, user: user)
    end
  end

  factory :identity do
    uid { Faker::Number.number(6) }
    access_token { Faker::Crypto.sha1 }
    time_zone { 'America/Los_Angeles' }

    trait :fitbit do
      provider { 'fitbit_oauth2' }
      expires_at { Time.now.to_i + 100 }
    end

    trait :strava do
      provider { 'strava' }
    end
  end

  factory :user_activity do
    association :user

    uid { Faker::Number.number(6) }
    distance { Faker::Number.number(4) }
    duration { Faker::Number.number(4) }
    start_time { Faker::Time.between(DateTime.now - 1, DateTime.now) }

    trait :fitbit do
      activity_type { 'Activity::FitbitRun' }
    end

    trait :strava do
      activity_type { 'Activity::StravaRun' }
    end
  end

  factory :activity_fitbit_run, class: 'Activity::FitbitRun' do
    association :user
    association :user_activity, :fitbit

    trait :with_gps_data do
      gps_data do
        {
          'raw' => [
            {
              'datetime' => '2016-07-31T12:00:00.000-07:00',
              'coordinate' => [Faker::Address.longitude,Faker::Address.latitude],
              'distance' => 0.0,
              'altitude' => Faker::Number.decimal(2),
              'heart_rate' => Faker::Number.number(10)
            }
          ],
          'derived' => {
            'bounds' => {
              'north' => Faker::Address.latitude,
              'east' => Faker::Address.longitude,
              'south' => Faker::Address.latitude,
              'west' => Faker::Address.longitude
            },
            'markers' => [
              [Faker::Address.longitude,Faker::Address.latitude]
            ]
          }
        }
      end
    end
  end

  factory :activity_strava_run, class: 'Activity::StravaRun' do
    association :user
    association :user_activity, :strava

    splits do
      { 'standard' => [] }
    end
  end
end
