class Task < ApplicationRecord
  include Searchable

  belongs_to :project, counter_cache: true, touch: true

  enum status: { not_started: 'not_started', in_progress: 'in_progress', completed: 'completed' }

  validates :name, presence: true
  validates :description, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }

  def as_indexed_json(_options = {})
    {
      name: name,
      description: description,
      status: status,
      project_id: project_id,
      created_at: created_at
    }
  end

  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :name, type: 'text', analyzer: 'english'
      indexes :description, type: 'text', analyzer: 'english'
      indexes :status, type: 'keyword'
      indexes :project_id, type: 'integer'
    end
  end
end
