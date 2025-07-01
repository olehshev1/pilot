# Ensure OpenAI API key is configured
if Rails.env.production? || Rails.env.staging?
  if Rails.application.credentials.openai.blank? || Rails.application.credentials.openai[:api_key].blank?
    Rails.logger.warn 'OpenAI API key is not configured in credentials'
  end
end

# Configure OpenAI client defaults
OpenAI.configure do |config|
  if Rails.application.credentials.openai.present?
    config.access_token = Rails.application.credentials.openai[:api_key]
    config.request_timeout = 30 # seconds
    config.log_errors = Rails.env.development?
  end
end if defined?(OpenAI)
