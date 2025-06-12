module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    def as_indexed_json(_options = {})
      as_json(only: [ :name, :description, :status, :project_id ])
    end

    def self.search(query, filters = {})
      search_definition = {
        query: {
          bool: {
            must: [],
            filter: []
          }
        }
      }

      # Add query conditions
      if query.present?
        search_definition[:query][:bool][:must] << {
          bool: {
            should: [
              {
                match: {
                  name: {
                    query: query,
                    boost: 3,
                    fuzziness: 'AUTO'
                  }
                }
              },
              {
                match: {
                  description: {
                    query: query,
                    fuzziness: 'AUTO'
                  }
                }
              }
            ],
            minimum_should_match: 1
          }
        }
      end

      # Add filters
      filters.each do |key, value|
        next if value.blank?

        if value.is_a?(Hash)
          # Handle nested filters
          value.each do |nested_key, nested_value|
            next if nested_value.blank?
            search_definition[:query][:bool][:filter] << {
              term: { "#{key}.#{nested_key}" => nested_value }
            }
          end
        else
          # Handle direct filters
          search_definition[:query][:bool][:filter] << {
            term: { key => value }
          }
        end
      end

      __elasticsearch__.search(search_definition)
    end
  end

  class_methods do
    def settings_attributes
      {
        index: {
          analysis: {
            analyzer: {
              autocomplete: {
                type: :custom,
                tokenizer: :standard,
                filter: [ :lowercase, :autocomplete ]
              }
            },
            filter: {
              autocomplete: {
                type: :edge_ngram,
                min_gram: 2,
                max_gram: 25
              }
            }
          }
        }
      }
    end

    def create_index!
      client = __elasticsearch__.client

      begin
        client.indices.delete index: index_name
      rescue
        # Index does not exist
      end

      client.indices.create(
        index: index_name,
        body: {
          settings: settings.to_hash,
          mappings: mappings.to_hash
        }
      )
    end

    def import_data
      import force: true
      __elasticsearch__.refresh_index!
    end
  end
end
