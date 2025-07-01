module LanguageLearning
  class Base < Openai::Base
    # Language mappings for AI prompts
    LANGUAGE_NAMES = {
      'ukrainian' => 'Ukrainian',
      'english' => 'English',
      'polish' => 'Polish'
    }.freeze

    SUPPORTED_LANGUAGES = %w[ukrainian english polish].freeze

    attr_reader :errors

    def initialize
      super
      @errors = []
    end

    def success?
      @errors.empty?
    end

    private

    def language_name(language_code)
      LANGUAGE_NAMES[language_code.to_s] || language_code.to_s.capitalize
    end

    def validate_language(language)
      unless SUPPORTED_LANGUAGES.include?(language.to_s)
        @errors << "Unsupported language: #{language}. Supported: #{SUPPORTED_LANGUAGES.join(', ')}"
        return false
      end
      true
    end

    def validate_languages(languages)
      languages.all? { |lang| validate_language(lang) }
    end

    def structured_response_prompt
      "\n\nPlease respond with a valid JSON object only, no additional text."
    end

    def safe_json_parse(text)
      # Extract JSON from response if it contains additional text
      json_match = text.match(/\{.*\}/m)
      json_text = json_match ? json_match[0] : text

      JSON.parse(json_text)
    rescue JSON::ParserError => e
      Rails.logger.error("JSON Parse Error: #{e.message}, Text: #{text}")
      nil
    end

    # Common OpenAI request handling
    def make_openai_request(prompt, temperature: 0.3, max_tokens: 800)
      return nil if prompt.blank?

      begin
        response = openai_client.chat(
          parameters: {
            model: 'gpt-4o-mini',
            messages: [ { role: 'user', content: prompt } ],
            temperature: temperature,
            max_tokens: max_tokens
          }
        )

        response.dig('choices', 0, 'message', 'content')
      rescue Faraday::Error => e
        handle_openai_error(e)
        nil
      rescue StandardError => e
        Rails.logger.error("OpenAI request error: #{e.message}")
        @errors << "Request failed: #{e.message}"
        nil
      end
    end
  end
end
