require 'swagger_helper'
require 'schemas/tasks'

RSpec.describe 'API V1 Tasks', type: :request do
  let(:user) { create(:user) }
  let(:token) { user.authentication_token }
  let(:email) { user.email }
  let(:project) { create(:project, user: user) }

  path '/api/v1/projects/{project_id}/tasks' do
    parameter name: 'project_id', in: :path, type: :integer, required: true
    parameter name: 'X-User-Token', in: :header, type: :string, required: true
    parameter name: 'X-User-Email', in: :header, type: :string, required: true

    let(:project_id) { project.id }

    get 'Lists all tasks for a project' do
      tags 'Tasks'
      consumes 'application/json'
      produces 'application/json'
      security [ { x_auth_token: [], x_auth_email: [] } ]

      response '200', 'tasks found' do
        schema schema_data_obj(Schemas::Tasks::TASKS_COLLECTION_SCHEMA)
        let(:'X-User-Token') { token }
        let(:'X-User-Email') { email }

        before do
          create_list(:task, 3, project: project)
        end

        run_test_with_example!
      end

      response '401', 'unauthorized' do
        let(:'X-User-Token') { 'invalid' }
        let(:'X-User-Email') { email }

        run_test!
      end

      response '403', 'forbidden' do
        let(:other_user) { create(:user) }
        let(:other_project) { create(:project, user: other_user) }
        let(:project_id) { other_project.id }
        let(:'X-User-Token') { token }
        let(:'X-User-Email') { email }

        run_test!
      end
    end

    post 'Creates a task' do
      tags 'Tasks'
      consumes 'application/json'
      produces 'application/json'
      security [ { x_auth_token: [], x_auth_email: [] } ]
      parameter name: 'X-User-Token', in: :header, type: :string, required: true
      parameter name: 'X-User-Email', in: :header, type: :string, required: true
      parameter name: :task, in: :body, schema: Schemas::Tasks::TASK_REQUEST_SCHEMA

      response '201', 'task created' do
        schema schema_data_obj(Schemas::Tasks::TASK_RESPONSE_SCHEMA)
        let(:'X-User-Token') { token }
        let(:'X-User-Email') { email }
        let(:task) { { task: { name: 'Test Task', description: 'This is a test task description', status: 'not_started' } } }

        run_test_with_example!
      end

      response '422', 'invalid request' do
        let(:'X-User-Token') { token }
        let(:'X-User-Email') { email }
        let(:task) { { task: { name: '', description: '', status: nil } } }

        run_test!
      end
    end
  end

  path '/api/v1/projects/{project_id}/tasks/{id}' do
    parameter name: 'project_id', in: :path, type: :integer, required: true
    parameter name: 'id', in: :path, type: :integer, required: true
    parameter name: 'X-User-Token', in: :header, type: :string, required: true
    parameter name: 'X-User-Email', in: :header, type: :string, required: true

    let(:existing_task) { create(:task, project: project) }
    let(:project_id) { project.id }
    let(:id) { existing_task.id }

    get 'Retrieves a task' do
      tags 'Tasks'
      consumes 'application/json'
      produces 'application/json'
      security [ { x_auth_token: [], x_auth_email: [] } ]

      response '200', 'task found' do
        schema schema_data_obj(Schemas::Tasks::TASK_RESPONSE_SCHEMA)
        let(:'X-User-Token') { token }
        let(:'X-User-Email') { email }

        run_test_with_example!
      end

      response '404', 'task not found' do
        let(:'X-User-Token') { token }
        let(:'X-User-Email') { email }
        let(:id) { 999999 }

        run_test!
      end

     response '403', 'forbidden' do
        let(:other_user) { create(:user) }
        let(:other_project) { create(:project, user: other_user) }
        let(:other_task) { create(:task, project: other_project) }
        let(:project_id) { other_project.id }
        let(:id) { other_task.id }
        let(:'X-User-Token') { token }
        let(:'X-User-Email') { email }

        run_test!
      end
    end

    put 'Updates a task' do
      tags 'Tasks'
      consumes 'application/json'
      produces 'application/json'
      security [ { x_auth_token: [], x_auth_email: [] } ]
      parameter name: :task, in: :body, schema: Schemas::Tasks::TASK_REQUEST_SCHEMA

      response '200', 'task updated' do
        schema schema_data_obj(Schemas::Tasks::TASK_RESPONSE_SCHEMA)
        let(:'X-User-Token') { token }
        let(:'X-User-Email') { email }
        let(:task) { { task: { name: 'Updated Task', description: 'This is an updated task description', status: 'in_progress' } } }

        run_test_with_example!
      end

      response '422', 'invalid request' do
        let(:'X-User-Token') { token }
        let(:'X-User-Email') { email }
        let(:task) { { task: { name: '', description: '', status: nil } } }

        run_test!
      end
    end

    delete 'Deletes a task' do
      tags 'Tasks'
      consumes 'application/json'
      produces 'application/json'
      security [ { x_auth_token: [], x_auth_email: [] } ]

      response '204', 'task deleted' do
        let(:'X-User-Token') { token }
        let(:'X-User-Email') { email }

        run_test!
      end
    end
  end
end
