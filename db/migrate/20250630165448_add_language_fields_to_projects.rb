class AddLanguageFieldsToProjects < ActiveRecord::Migration[7.2]
  def change
    add_column :projects, :source_language, :string
    add_column :projects, :target_languages, :text
    add_column :projects, :learning_context, :text
  end
end
