module Openai
  class Base < ApplicationService
    def call
      # Base implementation - to be overridden by subclasses
      self
    end

    private

    def openai_client
      @openai_client ||= OpenAI::Client.new(
        access_token: Rails.application.credentials.openai[:api_key],
        log_errors: Rails.env.development?
      )
    end

    def handle_openai_error(error)
      Rails.logger.error("OpenAI API Error: #{error.message}")
      @errors << "Failed to communicate with OpenAI: #{error.message}"
    end
  end
end
