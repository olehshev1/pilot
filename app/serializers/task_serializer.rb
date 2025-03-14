class TaskSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :status, :project_link

  belongs_to :project
end
