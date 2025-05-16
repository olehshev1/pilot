require 'elasticsearch/model'

config = {
  hosts: [
    {
      host: ENV['ELASTICSEARCH_HOST'] || 'elasticsearch',
      port: ENV['ELASTICSEARCH_PORT'] || 9200,
      user: ENV['ELASTICSEARCH_USER'],
      password: ENV['ELASTICSEARCH_PASSWORD'],
      scheme: ENV['ELASTICSEARCH_SCHEME'] || 'http'
    }
  ],
  retry_on_failure: true,
  transport_options: {
    request: { timeout: 5 }
  }
}

Elasticsearch::Model.client = Elasticsearch::Client.new(config)
