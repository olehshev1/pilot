require 'swagger_helper'
require 'schemas/tasks'

RSpec.describe 'API V1 Tasks', type: :request do
  let(:user) { create(:user) }
  let(:token) { user.authentication_token }
  let(:email) { user.email }
  let(:project) { create(:project, user: user) }

  path '/api/v1/projects/{project_id}/tasks' do
    parameter name: 'project_id', in: :path, type: :integer, required: true
    auth_parameters

    let(:project_id) { project.id }

    get 'Lists all tasks for a project' do
      tags 'Tasks'
      consumes 'application/json'
      produces 'application/json'
      auth_security

      response '200', 'tasks found' do
        schema schema_data_obj(Schemas::Tasks::TASKS_COLLECTION_SCHEMA)
        authenticate_with_token

        before do
          create_list(:task, 3, project: project)
        end

        run_test_with_example!
      end

      response '404', 'project not found' do
        authenticate_with_token
        let(:project_id) { 999999 }

        run_test!
      end
    end

    post 'Creates a task' do
      tags 'Tasks'
      consumes 'application/json'
      produces 'application/json'
      auth_security
      parameter name: :task, in: :body, schema: Schemas::Tasks::TASK_REQUEST_SCHEMA

      response '201', 'task created' do
        schema schema_data_obj(Schemas::Tasks::TASK_RESPONSE_SCHEMA)
        authenticate_with_token

        let(:task) do
          { task: { name: 'Test Task', description: 'This is a test task', status: 'not_started' } }
        end

        run_test_with_example!
      end

      response '422', 'invalid request' do
        authenticate_with_token
        let(:task) { { task: { name: '', description: '', status: '' } } }

        run_test!
      end
    end
  end

  path '/api/v1/projects/{project_id}/tasks/{id}' do
    parameter name: 'project_id', in: :path, type: :integer, required: true
    parameter name: 'id', in: :path, type: :integer, required: true
    auth_parameters

    let(:existing_task) { create(:task, project: project) }
    let(:project_id) { project.id }
    let(:id) { existing_task.id }

    get 'Fetches a task' do
      tags 'Tasks'
      consumes 'application/json'
      produces 'application/json'
      auth_security

      response '200', 'task found' do
        schema schema_data_obj(Schemas::Tasks::TASK_RESPONSE_SCHEMA)
        authenticate_with_token

        run_test_with_example!
      end

      response '404', 'task not found' do
        authenticate_with_token
        let(:id) { 999999 }

        run_test!
      end
    end

    put 'Updates a task' do
      tags 'Tasks'
      consumes 'application/json'
      produces 'application/json'
      auth_security
      parameter name: :task, in: :body, schema: Schemas::Tasks::TASK_REQUEST_SCHEMA

      response '200', 'task updated' do
        schema schema_data_obj(Schemas::Tasks::TASK_RESPONSE_SCHEMA)
        authenticate_with_token
        let(:task) do
          { task: { name: 'Updated Task', description: 'This is an updated task', status: 'in_progress' } }
        end

        run_test_with_example!
      end

      response '422', 'invalid request' do
        authenticate_with_token
        let(:task) { { task: { name: '', description: '', status: '' } } }

        run_test!
      end
    end

    delete 'Deletes a task' do
      tags 'Tasks'
      consumes 'application/json'
      produces 'application/json'
      auth_security

      response '204', 'task deleted' do
        authenticate_with_token

        run_test!
      end
    end
  end

  path '/api/v1/search/tasks' do
    get 'Search tasks' do
      tags 'Search'
      consumes 'application/json'
      produces 'application/json'
      auth_security
      auth_parameters
      parameter name: :q, in: :query, type: :string, required: true
      parameter name: :project_id, in: :query, type: :integer, required: false
      parameter name: :status, in: :query, type: :string, required: false

      response '200', 'tasks found' do
        authenticate_with_token
        let(:q) { 'test' }
        let!(:task) { create(:task, name: 'Test Task', description: 'Task Description', project:) }

        before do
          Task.create_index!
          Task.import_data
          Task.__elasticsearch__.refresh_index!
          sleep 1
        end

        run_test_with_example! do
          expect(json_response['tasks']).to be_present
          expect(json_response['tasks'].first['name']).to eq('Test Task')
        end
      end

      response '200', 'tasks filtered by project' do
        authenticate_with_token
        let(:q) { 'test' }
        let(:project_id) { project.id }
        let!(:task) { create(:task, name: 'Test Task', description: 'Task Description', project:) }

        before do
          Task.create_index!
          Task.import_data
          Task.__elasticsearch__.refresh_index!
          sleep 1
        end

        run_test_with_example! do
          expect(json_response['tasks']).to be_present
          expect(json_response['tasks'].first['project_id']).to eq(project.id)
        end
      end

      response '200', 'tasks filtered by status' do
        authenticate_with_token
        let(:q) { 'test' }
        let(:status) { 'in_progress' }
        let!(:task) { create(:task, name: 'Test Task', description: 'Task Description', project:, status: 'in_progress') }

        before do
          Task.create_index!
          Task.import_data
          Task.__elasticsearch__.refresh_index!
          sleep 1
        end

        run_test_with_example! do
          expect(json_response['tasks']).to be_present
          expect(json_response['tasks'].first['status']).to eq('in_progress')
        end
      end

      response '200', 'no tasks found' do
        authenticate_with_token
        let(:q) { 'nonexistent' }

        run_test_with_example! do
          expect(json_response['tasks']).to be_empty
        end
      end

      response '401', 'unauthorized' do
        let(:q) { 'test' }
        let(:'X-User-Token') { 'invalid' }
        let(:'X-User-Email') { email }

        run_test! do |response|
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
