module LanguageLearning
  class WordProcessor < Base
    attr_reader :word, :source_language, :target_languages, :context
    attr_reader :translations, :examples, :word_info, :processing_results

    def initialize(word, source_language, target_languages, context: nil)
      super()
      @word = word.to_s.strip
      @source_language = source_language.to_s
      @target_languages = Array(target_languages).map(&:to_s)
      @context = context.to_s.strip
      @translations = {}
      @examples = {}
      @word_info = {}
      @processing_results = {}
    end

    def call
      return self if @word.blank?
      return self unless validate_languages([ @source_language ] + @target_languages)

      # Step 1: Translate the word
      translate_word
      return self unless translation_successful?

      # Step 2: Generate examples for each target language
      generate_examples_for_all_languages

      # Step 3: Compile final results
      compile_processing_results

      self
    end

    def success?
      super && @translations.any?
    end

    def translation_successful?
      @translations.any? && @translation_service&.success?
    end

    def examples_generated?
      @examples.any?
    end

    def create_task_data
      return nil unless success?

      {
        original_word: @word,
        translations: @translations.to_json,
        examples: @examples.to_json,
        learning_status: 'new',
        name: build_task_name,
        description: build_task_description
      }
    end

    private

    def translate_word
      @translation_service = LanguageLearning::Translator.call(
        @word,
        @source_language,
        @target_languages,
        context: @context
      )

      if @translation_service.success?
        @translations = @translation_service.translations
        @word_info = @translation_service.word_info
      else
        @errors.concat(@translation_service.errors)
      end
    end

    def generate_examples_for_all_languages
      @target_languages.each do |language|
        generate_examples_for_language(language)
      end
    end

    def generate_examples_for_language(language)
      translations_for_lang = @translations[language] || []
      return if translations_for_lang.empty?

      example_service = LanguageLearning::ExampleGenerator.call(
        @word,
        translations_for_lang,
        language,
        context: @context
      )

      if example_service.success?
        @examples[language] = {
          'examples' => example_service.examples,
          'learning_tips' => example_service.learning_tips
        }
      else
        Rails.logger.warn("Examples generation failed for #{language}: #{example_service.errors}")
        # Don't fail the whole process if examples fail
        @examples[language] = { 'examples' => [], 'learning_tips' => [] }
      end
    end

    def compile_processing_results
      @processing_results = {
        word: @word,
        source_language: @source_language,
        target_languages: @target_languages,
        context: @context,
        translations: @translations,
        examples: @examples,
        word_info: @word_info,
        processing_stats: {
          translations_count: @translations.values.flatten.size,
          examples_count: @examples.values.sum { |lang_data| lang_data['examples'].size },
          languages_processed: @target_languages.size
        }
      }
    end

    def build_task_name
      translations_preview = @target_languages.map do |lang|
        first_translation = @translations[lang]&.first
        first_translation ? "#{language_name(lang)}: #{first_translation}" : nil
      end.compact.join(' | ')

      "#{@word} → #{translations_preview}"
    end

    def build_task_description
      context_part = @context.present? ? "Context: #{@context}\n\n" : ''

      description_parts = []

      @target_languages.each do |language|
        lang_translations = @translations[language] || []
        next if lang_translations.empty?

        lang_name = language_name(language)
        translations_text = lang_translations.join(', ')
        description_parts << "#{lang_name}: #{translations_text}"
      end

      word_info_part = ''
      if @word_info.any?
        info_items = []
        info_items << "Part of speech: #{@word_info['part_of_speech']}" if @word_info['part_of_speech']
        info_items << "Difficulty: #{@word_info['difficulty']}" if @word_info['difficulty']
        word_info_part = "\n\n#{info_items.join(' | ')}" if info_items.any?
      end

      "#{context_part}#{description_parts.join("\n")}#{word_info_part}"
    end
  end
end
