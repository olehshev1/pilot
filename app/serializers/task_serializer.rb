class TaskSerializer < BaseSerializer
  attributes :id, :name, :description, :status

  belongs_to :project
end
