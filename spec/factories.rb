FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password 'abc123'
    password_confirmation 'abc123'
  end

  factory :identity do
    uid { Faker::Number.number(6) }
    access_token { Faker::Crypto.sha1 }

    trait :fitbit do
      provider { 'fitbit_oauth2' }
    end

    trait :strava do
      provider { 'strava' }
    end
  end

  factory :user_activity do
    uid { Faker::Number.number(6) }

    trait :fitbit do
      activity_type { 'Activity::FitbitRun' }
    end

    trait :strava do
      activity_type { 'Activity::StravaRun' }
    end
  end

  factory :activity_fitbit_run, class: 'Activity::FitbitRun' do
    association :user_activity

    trait :with_gps_data do
      gps_data do
        {
          'raw' => [
            {
              'datetime' => '2016-07-31T12:00:00.000-07:00',
              'coordinate' => [Faker::Address.longitude,Faker::Address.latitude],
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
            }
          }
        }
      end
    end
  end

  factory :activity_strava_run, class: 'Activity::StravaRun' do
    association :user_activity
  end
end
