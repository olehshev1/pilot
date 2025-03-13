class AddProjectsCountToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :projects_count, :integer, default: 0, null: false
  end
end
