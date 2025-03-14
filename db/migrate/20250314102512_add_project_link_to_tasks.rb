class AddProjectLinkToTasks < ActiveRecord::Migration[7.2]
  def change
    add_column :tasks, :project_link, :string
  end
end
