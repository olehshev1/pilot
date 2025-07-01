class Task < ApplicationRecord
  include LanguageLearningAttributes

  belongs_to :project, counter_cache: true, touch: true

  enum status: { not_started: 'not_started', in_progress: 'in_progress', completed: 'completed' }

  # Language Learning statuses
  enum learning_status: {
    new: 'new',
    learning: 'learning',
    practiced: 'practiced',
    mastered: 'mastered'
  }, _suffix: true

  validates :name, presence: true
  validates :description, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :learning_status, presence: true, inclusion: { in: learning_statuses.keys }
  validates :original_word, presence: true, if: :word_translation_task?

  # Language Learning methods
  def translations_hash
    safe_parse_json_attribute(translations, {})
  end

  def translations_hash=(translations_data)
    self.translations = safe_set_json_attribute(translations_data)
  end

  def examples_hash
    safe_parse_json_attribute(examples, {})
  end

  def examples_hash=(examples_data)
    self.examples = safe_set_json_attribute(examples_data)
  end

  def word_translation_task?
    original_word.present?
  end

  def translation_for(language)
    translations_hash[language.to_s]
  end

  def examples_for(language)
    examples_hash[language.to_s] || []
  end

  def add_translation(language, translation_text)
    current_translations = translations_hash
    current_translations[language.to_s] = translation_text
    self.translations_hash = current_translations
  end

  def add_examples(language, examples_array)
    current_examples = examples_hash
    current_examples[language.to_s] = examples_array
    self.examples_hash = current_examples
  end

  def learning_progress_percentage
    case learning_status
    when 'new' then 0
    when 'learning' then 25
    when 'practiced' then 75
    when 'mastered' then 100
    else 0
    end
  end

  def can_advance_learning?
    !mastered_learning_status?
  end

  def advance_learning_status!
    case learning_status
    when 'new' then learning_learning_status!
    when 'learning' then practiced_learning_status!
    when 'practiced' then mastered_learning_status!
    end
  end
end
