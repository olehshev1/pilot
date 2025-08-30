class Project < ApplicationRecord
  include LanguageLearningAttributes

  NAME_MIN_LENGTH = 5
  NAME_MAX_LENGTH = 20
  DESCRIPTION_MIN_LENGTH = 20
  DESCRIPTION_MAX_LENGTH = 120

  # Language Learning constants
  SUPPORTED_LANGUAGES = %w[ukrainian english polish].freeze
  DEFAULT_SOURCE_LANGUAGE = 'ukrainian'.freeze
  DEFAULT_TARGET_LANGUAGES = %w[english polish].freeze

  belongs_to :user, counter_cache: true, touch: true
  has_many :tasks, dependent: :restrict_with_error

  validates :name, presence: true, length: { minimum: NAME_MIN_LENGTH, maximum: NAME_MAX_LENGTH }
  validates :description, presence: true, length: { minimum: DESCRIPTION_MIN_LENGTH, maximum: DESCRIPTION_MAX_LENGTH }
  validates :source_language, presence: true, inclusion: { in: SUPPORTED_LANGUAGES }

  validates_with ProjectDeletionValidator, on: :destroy

  # Language Learning methods
  def target_languages_array
    safe_parse_json_attribute(target_languages, DEFAULT_TARGET_LANGUAGES)
  end

  def target_languages_array=(languages)
    self.target_languages = safe_set_json_attribute(languages)
  end

  def learning_session?
    source_language.present? && target_languages_array.any?
  end

  def supports_language?(language)
    SUPPORTED_LANGUAGES.include?(language.to_s)
  end

  def language_pair_name
    return "#{source_language} → #{target_languages_array.join(', ')}" if learning_session?
    'General Project'
  end
end
