require 'swagger_helper'

RSpec.describe 'API V1 Search', type: :request do
  let(:user) { create(:user) }
  let(:token) { user.authentication_token }
  let(:email) { user.email }
  let!(:project) { create(:project,
    name: 'Test Project',
    description: 'This is a test project description that meets the minimum length requirement',
    user:) }
  let!(:task) { create(:task,
    name: 'Test Task',
    description: 'This is a test task description that meets the minimum length requirement',
    project:) }

  before do
    Project.create_index!
    Project.import_data
    Project.__elasticsearch__.refresh_index!
    Task.create_index!
    Task.import_data
    Task.__elasticsearch__.refresh_index!
    sleep 1
  end

  path '/api/v1/search' do
    get 'Search across all models' do
      tags 'Search'
      consumes 'application/json'
      produces 'application/json'
      auth_security
      auth_parameters
      parameter name: :q, in: :query, type: :string, required: true

      response '200', 'search results found' do
        authenticate_with_token
        let(:q) { 'test' }

        run_test_with_example! do
          expect(json_response['results']['projects']).to be_present
          expect(json_response['results']['tasks']).to be_present
          expect(json_response['results']['projects'].first['name']).to eq('Test Project')
          expect(json_response['results']['tasks'].first['name']).to eq('Test Task')
        end
      end

      response '200', 'no results found' do
        authenticate_with_token
        let(:q) { 'nonexistent' }

        run_test_with_example! do
          expect(json_response['results']['projects']).to be_empty
          expect(json_response['results']['tasks']).to be_empty
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
