class ProjectSerializer < BaseSerializer
  attributes :id, :name, :description, :source_language, :target_languages,
             :learning_context, :language_pair_name, :learning_session, :created_at, :updated_at

  belongs_to :user
  has_many :tasks

  def target_languages
    object.target_languages_array
  end

  def language_pair_name
    object.language_pair_name
  end

  def learning_session
    object.learning_session?
  end
end
