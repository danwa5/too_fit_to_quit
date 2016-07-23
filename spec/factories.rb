FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password 'abc123'
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
end
