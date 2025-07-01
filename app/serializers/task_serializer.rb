class TaskSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :status, :original_word, :learning_status,
             :translations, :examples, :learning_progress, :created_at, :updated_at

  belongs_to :project

  def translations
    object.translations_hash
  end

  def examples
    object.examples_hash
  end

  def learning_progress
    object.learning_progress_percentage
  end
end
