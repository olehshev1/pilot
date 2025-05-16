# Elasticsearch Integration

## Overview

The application uses Elasticsearch for full-text search capabilities across Projects and Tasks.

## Infrastructure

- Elasticsearch 8.12.1 running in Docker
- Kibana for visualization and index management
- Configured networks and volumes for data persistence

## Models and Search

- `Searchable` concern with Elasticsearch configuration
- Integration with `Project` and `Task` models
- Configured mappings and analyzers for search

### Searchable Concern Features

- Full-text search on name and description fields
- Fuzzy matching for better search results
- Custom analyzers for autocomplete functionality
- Filtering by user_id and status

## API Endpoints

- `/api/v1/search` - General search across all models
- `/api/v1/search/projects` - Project-specific search
- `/api/v1/search/tasks` - Task-specific search

### Search Parameters

- `q` - Search query
- `project_id` - Filter tasks by project (for task search)
- `status` - Filter by status (for task search)

## Setup and Maintenance

### Initial Setup

1. Start containers:

```bash
docker-compose up -d
```

2. Create indices:

```bash
docker exec -it pilot-app-1 rake elasticsearch:create_indices
```

3. Import data:

```bash
docker exec -it pilot-app-1 rake elasticsearch:import_data
```

### Maintenance Tasks

- `rake elasticsearch:create_indices` - Create/update indices
- `rake elasticsearch:import_data` - Import data into indices
- `rake elasticsearch:reindex` - Full reindex (drop, create, import)

## Monitoring

- Kibana available at http://localhost:5601
- Elasticsearch available at http://localhost:9200

## Configuration

Elasticsearch configuration is managed through:

- `config/initializers/elasticsearch.rb` - Client configuration
- `app/models/concerns/searchable.rb` - Search settings and mappings
- `docker-compose.yml` - Container and environment settings

## Example Requests and Responses

### Direct Elasticsearch Queries

#### 1. Basic Search

```bash
# Request
curl -X GET "http://localhost:9200/projects/_search?q=test"

# Response
{
   "_shards": {
      "failed": 0,
      "skipped": 0,
      "successful": 1,
      "total": 1
   },
   "hits": {
      "hits": [
         {
            "_id": "FPP025YBMizhsI0J3ET0",
            "_index": "projects",
            "_score": 1.3193506,
            "_source": {
               "description": "This is a test project",
               "name": "Test Project"
            }
         }
      ],
      "max_score": 1.3193506,
      "total": {
         "relation": "eq",
         "value": 1
      }
   },
   "timed_out": false,
   "took": 38
}
```

#### 2. Field-Specific Search

```bash
# Request
curl -X GET "http://localhost:9200/projects/_search" -H "Content-Type: application/json" -d '{
  "query": {
    "match": {
      "name": "test"
    }
  }
}'

# Response
{
  "took": 5,
  "timed_out": false,
  "_shards": {
    "total": 1,
    "successful": 1,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": {
      "value": 1,
      "relation": "eq"
    },
    "max_score": 0.6931471,
    "hits": [
      {
        "_index": "projects",
        "_id": "FPP025YBMizhsI0J3ET0",
        "_score": 0.6931471,
        "_source": {
          "name": "Test Project",
          "description": "This is a test project"
        }
      }
    ]
  }
}
```

#### 3. Multi-Field Search

```bash
# Request
curl -X GET "http://localhost:9200/projects/_search" -H "Content-Type: application/json" -d '{
  "query": {
    "multi_match": {
      "query": "test",
      "fields": ["name", "description"]
    }
  }
}'

# Response
{
  "took": 12,
  "timed_out": false,
  "_shards": {
    "total": 1,
    "successful": 1,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": {
      "value": 1,
      "relation": "eq"
    },
    "max_score": 0.8630463,
    "hits": [
      {
        "_index": "projects",
        "_id": "FPP025YBMizhsI0J3ET0",
        "_score": 0.8630463,
        "_source": {
          "name": "Test Project",
          "description": "This is a test project"
        }
      }
    ]
  }
}
```

#### 4. Create Document

```bash
# Request
curl -X POST "http://localhost:9200/projects/_doc" -H "Content-Type: application/json" -d '{
  "name": "New Project",
  "description": "Project description"
}'

# Response
{
  "_index": "projects",
  "_id": "FPP025YBMizhsI0J3ET0",
  "_version": 1,
  "result": "created",
  "_shards": {
    "total": 2,
    "successful": 1,
    "failed": 0
  },
  "_seq_no": 1,
  "_primary_term": 3
}
```

#### 5. Update Document

```bash
# Request
curl -X POST "http://localhost:9200/projects/_update/FPP025YBMizhsI0J3ET0" -H "Content-Type: application/json" -d '{
  "doc": {
    "name": "Updated Project Name"
  }
}'

# Response
{
  "_index": "projects",
  "_id": "FPP025YBMizhsI0J3ET0",
  "_version": 2,
  "result": "updated",
  "_shards": {
    "total": 2,
    "successful": 1,
    "failed": 0
  },
  "_seq_no": 2,
  "_primary_term": 3
}
```

#### 6. Delete Document

```bash
# Request
curl -X DELETE "http://localhost:9200/projects/_doc/FPP025YBMizhsI0J3ET0"

# Response
{
  "_index": "projects",
  "_id": "FPP025YBMizhsI0J3ET0",
  "_version": 3,
  "result": "deleted",
  "_shards": {
    "total": 2,
    "successful": 1,
    "failed": 0
  },
  "_seq_no": 3,
  "_primary_term": 3
}
```

#### 7. Complex Search with Filtering

```bash
# Request
curl -X GET "http://localhost:9200/projects/_search" -H "Content-Type: application/json" -d '{
  "query": {
    "bool": {
      "must": [
        { "match": { "name": "test" } }
      ],
      "filter": [
        { "term": { "status": "active" } }
      ]
    }
  }
}'

# Response
{
  "took": 6,
  "timed_out": false,
  "_shards": {
    "total": 1,
    "successful": 1,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": {
      "value": 1,
      "relation": "eq"
    },
    "max_score": 0.6931471,
    "hits": [
      {
        "_index": "projects",
        "_id": "FPP025YBMizhsI0J3ET0",
        "_score": 0.6931471,
        "_source": {
          "name": "Test Project",
          "description": "This is a test project",
          "status": "active"
        }
      }
    ]
  }
}
```

### API Endpoints

#### 1. General Search

```bash
# Request
curl -X GET "http://localhost:3102/api/v1/search?q=test"

# Response
{
  "results": {
    "projects": [
      {
        "id": 1,
        "name": "Test Project",
        "description": "This is a test project",
        "created_at": "2024-03-14T10:00:00.000Z",
        "updated_at": "2024-03-14T10:00:00.000Z"
      }
    ],
    "tasks": []
  }
}
```

#### 2. Project-Specific Search

```bash
# Request
curl -X GET "http://localhost:3102/api/v1/search/projects?q=test"

# Response
{
  "projects": [
    {
      "id": 1,
      "name": "Test Project",
      "description": "This is a test project",
      "created_at": "2024-03-14T10:00:00.000Z",
      "updated_at": "2024-03-14T10:00:00.000Z"
    }
  ]
}
```

#### 3. Task-Specific Search

```bash
# Request
curl -X GET "http://localhost:3102/api/v1/search/tasks?q=test"

# Response
{
  "tasks": [
    {
      "id": 1,
      "title": "Test Task",
      "description": "This is a test task",
      "status": "pending",
      "project_id": 1,
      "created_at": "2024-03-14T10:00:00.000Z",
      "updated_at": "2024-03-14T10:00:00.000Z"
    }
  ]
}
```

### Notes

- All responses are in JSON format
- HTTP status codes:
  - 200: Successful request
  - 400: Bad request (invalid parameters)
  - 404: Not found
  - 500: Server error
- For API endpoints, authentication might be required (check the Authentication section)
- The search results are paginated by default (20 items per page)
- Use the `page` parameter to navigate through results: `?q=test&page=2`
