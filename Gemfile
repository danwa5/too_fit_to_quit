source 'https://rubygems.org'

ruby '2.2.3'

gem 'rails', '4.2.6'
gem 'pg', '~> 0.18.4'

# authentication
gem 'devise'
gem 'omniauth-fitbit-oauth2'
gem 'omniauth-strava-oauth2', '~> 0.0.2'

gem 'bootstrap-sass', '~> 3.3.6'
gem 'dry-initializer'
gem 'dry-monads'
gem 'dry-transaction'
gem 'figaro'
gem 'geocoder'
gem 'httparty'
gem 'jquery-rails'
gem 'react-rails', '~> 1.11'
gem 'redis', '~> 3.3', '>= 3.3.1'
gem 'redis-namespace', '~> 1.5', '>= 1.5.2'
gem 'sass-rails', '~> 5.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'selectize-rails'
gem 'sidekiq', '~> 4.1', '>= 4.1.4'
gem 'turbolinks', '~> 2.5'
gem 'uglifier', '>= 1.3.0'
gem 'underscore-rails', '~> 1.8', '>= 1.8.3'

group :production do
  gem 'puma', '~> 3.4'
  gem 'rails_12factor'
end

group :development, :test do
  gem 'rspec-rails', '~> 3.4', '>= 3.4.2'
  gem 'capybara', '~> 2.6', '>= 2.6.2'
  gem 'factory_girl_rails', '~> 4.6'
  gem 'faker'
  gem 'byebug'
  gem 'awesome_print'
end

group :test do
  gem 'database_cleaner', '~> 1.3.0'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'webmock'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spsring'
end
