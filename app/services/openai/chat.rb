module Openai
  class Chat < Base
    attr_reader :prompt, :response_text, :errors, :model

    def initialize(prompt, model: 'gpt-4o-mini')
      @prompt = prompt
      @model = model
      @errors = []
      @response_text = nil
    end

    def call
      return self if @prompt.blank?

      begin
        response = openai_client.chat(
          parameters: {
            model: @model,
            messages: [ { role: 'user', content: @prompt } ],
            temperature: 0.7,
            max_tokens: 500
          }
        )

        @response_text = response.dig('choices', 0, 'message', 'content')
        @errors << 'No response received from OpenAI' if @response_text.blank?

      rescue Faraday::Error => e
        handle_openai_error(e)
      rescue StandardError => e
        Rails.logger.error("Unexpected error in OpenAI Chat: #{e.message}")
        @errors << "An unexpected error occurred: #{e.message}"
      end

      self
    end

    def success?
      @errors.empty? && @response_text.present?
    end

    def status_error
      :service_unavailable
    end
  end
end
