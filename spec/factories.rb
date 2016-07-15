FactoryGirl.define do
  factory :user

  factory :identity do
    # association :user
    uid { Faker::Number.number(6) }
    provider { 'fitbit_oauth2' }
    access_token { Faker::Crypto.sha1 }
  end
end
