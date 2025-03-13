class Project < ApplicationRecord
  belongs_to :user, counter_cache: true
  has_many :tasks, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true
end
