FactoryBot.define do
  factory :task do
    name { "Sample Task" }
    description { "This is a sample task description" }
    status { "not_started" }
    project_link { "https://github.com/example/project" }
    association :project

    trait :in_progress do
      status { "in_progress" }
    end

    trait :completed do
      status { "completed" }
    end

    trait :invalid_project_link do
      project_link { "invalid-url" }
    end
  end
end
