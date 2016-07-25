redis_opts = { :url => (ENV['REDISTOGO_URL'] || Figaro.env.redis_url), namespace: 'too_fit_to_quit' }

Sidekiq.configure_server do |config|
  config.redis = redis_opts
end

Sidekiq.configure_client do |config|
  config.redis = redis_opts
end
