Bugsnag.configure do |config|
  config.api_key = Rails.application.credentials.dig(Rails.env.to_sym, :bugsnag_api_key)
end
