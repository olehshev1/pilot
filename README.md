# Test Assignment for RoR Developer: Project Management System

You are required to implement a simple Project Management System, allowing users to create, edit, and track projects and their tasks. The system should have a simple RESTful API for interaction with the frontend.

## Primary Requirements
### Database Modelling:
- Create `Project` and `Task` models.
- Projects should have a `title` and `description`.
- Tasks should have a `title`, `description`, `status` (new, in progress, completed) and a reference to project.
- Implement associations between projects and tasks.

### API Implementation:
- Develop an API for creating, updating, deleting, and viewing `projects` and `tasks`.
- Authenticate user via API (you can use `Devise` and `Simple token authentication`).

### Active Record Queries:
- Implement queries to obtain projects with all their tasks.
- Implement queries to filter tasks based on their status.

### Query and Code Optimization:
- Ensure your database queries are optimized (Use `includes`, `select`, `where`, etc).
- Implement caching for frequently used queries to boost performance.
- Adhere to Rails best practices for code optimization (DRY, SOLID principles).

### Writing Tests:
- Write `unit` and `integration` tests to validate functionality of models and API.
- Use `RSpec` or `Minitest` for writing tests.

### Additional Requirements:
- Code should be clean and well-organized.
- Use Git for maintaining version/change history.
- Pay attention to API security.

## Result:
Your task is to provide a link to your Git repository with the project and instructions on how to run it.

## Requirements:
- ruby 3.3.6

## Setup:
- overcommit --sign
- cp .env.example .env
- bundle install
- rails db:setup
- rails s -p 3000

## Usage

## Compose usage
```
docker compose run app rails db:create
docker compose run app rails db:environment:set RAILS_ENV=development

docker compose run app rake db:create
docker compose run app rake db:drop
docker compose run app rake db:schema:load
docker compose run app rake db:seed

docker exec -it pilot-app-1 rails g migration description_of_change
docker exec -it pilot-app-1 rails db:migrate
docker exec -it pilot-app-1 rails db:rollback

docker compose run app bundle update
docker compose run app bundle

docker exec -it pilot-app-1 rails c #console
docker attach pilot-app-1 #debug
docker exec -it pilot-app-1 rspec #test
docker exec -it pilot-app-1 /bin/bash #cli
```

## Documentation
- RAILS_ENV=test bundle exec rspec spec/requests/api/v1 --format Rswag::Specs::SwaggerFormatter
- open http://localhost:3000/api-docs/index.html
```
