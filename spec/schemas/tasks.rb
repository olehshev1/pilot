module Schemas
  module Tasks
    TASK_SCHEMA = {
      type: :object,
      properties: {
        id: { type: :integer },
        name: { type: :string },
        description: { type: :string },
        status: { type: :string, enum: %w[not_started in_progress completed] },
        project_id: { type: :integer },
        project_link: { type: :string }
      },
      required: %w[id name description status project_link]
    }.freeze

    TASK_REQUEST_SCHEMA = {
      type: :object,
      properties: {
        task: {
          type: :object,
          properties: {
            name: { type: :string },
            description: { type: :string },
            status: { type: :string, enum: %w[not_started in_progress completed] },
            project_link: { type: :string }
          },
          required: %w[name description status project_link]
        }
      },
      required: %w[task]
    }.freeze

    TASK_RESPONSE_SCHEMA = TASK_SCHEMA

    TASKS_COLLECTION_SCHEMA = {
      type: :array,
      items: TASK_SCHEMA
    }.freeze
  end
end
