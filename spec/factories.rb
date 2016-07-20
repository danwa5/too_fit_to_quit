FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password 'abc123'
  end

  factory :identity do
    # association :user
    uid { Faker::Number.number(6) }
    provider { 'fitbit_oauth2' }
    access_token { Faker::Crypto.sha1 }
  end
end
