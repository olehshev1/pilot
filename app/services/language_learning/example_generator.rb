module LanguageLearning
  class ExampleGenerator < Base
    attr_reader :word, :translations, :target_language, :context, :examples

    def initialize(word, translations, target_language, context: nil)
      super()
      @word = word.to_s.strip
      @translations = Array(translations)
      @target_language = target_language.to_s
      @context = context.to_s.strip
      @examples = []
    end

    def call
      return self if @word.blank? || @translations.empty?
      return self unless validate_language(@target_language)

      response_text = make_openai_request(
        build_examples_prompt,
        temperature: 0.5,
        max_tokens: 1000
      )

      if response_text.present?
        parse_examples_response(response_text)
      else
        @errors << 'No examples received from OpenAI'
      end

      self
    end

    def success?
      super && @examples.any?
    end

    def learning_tips
      @learning_tips || []
    end

    def grouped_examples
      @examples.group_by { |ex| ex['translation'] }
    end

    private

    def build_examples_prompt
      lang_name = language_name(@target_language)
      translations_list = @translations.join(', ')
      context_info = @context.present? ? "\nLearning context: #{@context}" : ''

      <<~PROMPT
        Create practical usage examples for #{lang_name} translations of "#{@word}".
        Translations: #{translations_list}#{context_info}

        Generate examples that:
        - Show different meanings and contexts
        - Are useful for language learning
        - Include both simple and complex sentences
        - Cover different scenarios (formal, informal, daily use)

        For each translation, provide 2-3 example sentences.

        Respond in this exact JSON format:
        {
          "examples": [
            {
              "translation": "translation_word",
              "sentences": [
                {
                  "sentence": "Example sentence in #{lang_name}",
                  "translation_back": "Translation back to original language",
                  "context": "formal/informal/daily/business",
                  "difficulty": "beginner/intermediate/advanced"
                }
              ]
            }
          ],
          "learning_tips": [
            "Tip 1 about usage",
            "Tip 2 about common mistakes"
          ]
        }#{structured_response_prompt}
      PROMPT
    end

    def parse_examples_response(response_text)
      parsed_data = safe_json_parse(response_text)

      if parsed_data && parsed_data['examples']
        @examples = parsed_data['examples']
        @learning_tips = parsed_data['learning_tips'] || []
      else
        @errors << 'Invalid examples response format'
      end
    end
  end
end
