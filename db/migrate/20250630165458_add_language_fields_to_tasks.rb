class AddLanguageFieldsToTasks < ActiveRecord::Migration[7.2]
  def change
    add_column :tasks, :original_word, :string
    add_column :tasks, :translations, :text
    add_column :tasks, :examples, :text
    add_column :tasks, :learning_status, :string
  end
end
