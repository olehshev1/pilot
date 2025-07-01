module LanguageLearning
  class Translator < Base
    attr_reader :word, :source_language, :target_languages, :context, :translations

    def initialize(word, source_language, target_languages, context: nil)
      super()
      @word = word.to_s.strip
      @source_language = source_language.to_s.strip
      @target_languages = Array(target_languages).map { |lang| lang.to_s.strip }
      @context = context.to_s.strip
      @translations = {}
    end

    def call
      return self if @word.blank?
      return self unless validate_languages([ @source_language ] + @target_languages)

      response_text = make_openai_request(build_translation_prompt)

      if response_text.present?
        parse_translation_response(response_text)
      else
        @errors << 'No translation received from OpenAI'
      end

      self
    end

    def success?
      super && @translations.any?
    end

    private

    def build_translation_prompt
      target_langs = @target_languages.map { |lang| language_name(lang) }.join(' and ')
      source_lang = language_name(@source_language)

      context_info = @context.present? ? "\nContext: #{@context}" : ''

      <<~PROMPT
        Translate the #{source_lang} word "#{@word}" to #{target_langs}.#{context_info}

        Provide translations with multiple meanings if applicable, and include:
        - Direct translations
        - Alternative meanings/synonyms
        - Usage notes if relevant

        Respond in this exact JSON format:
        {
          "translations": {
            #{@target_languages.map { |lang| "\"#{lang}\": [\"translation1\", \"translation2\"]" }.join(",\n            ")}
          },
          "word_info": {
            "part_of_speech": "noun/verb/adjective/etc",
            "pronunciation": "phonetic if helpful",
            "difficulty": "beginner/intermediate/advanced"
          }
        }#{structured_response_prompt}
      PROMPT
    end

    def parse_translation_response(response_text)
      parsed_data = safe_json_parse(response_text)

      if parsed_data && parsed_data['translations']
        @translations = parsed_data['translations']
        @word_info = parsed_data['word_info'] || {}
      else
        @errors << 'Invalid translation response format'
      end
    end

    def word_info
      @word_info || {}
    end
  end
end
