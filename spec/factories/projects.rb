FactoryBot.define do
  factory :project do
    name { "Sample Project" }
    description { "This is a sample project description that meets the minimum length requirement" }
    source_language { "ukrainian" }
    target_languages { '["english", "polish"]' }
    learning_context { "General language learning" }
    association :user

    trait :with_tasks do
      after(:create) do |project|
        create_list(:task, 3, project: project)
      end
    end

    trait :english_learning do
      name { "English Study" }
      description { "Learning English vocabulary and grammar through daily practice sessions" }
      source_language { "ukrainian" }
      target_languages { '["english"]' }
      learning_context { "Business English for IT professionals" }
    end

    trait :polish_learning do
      name { "Polish Study" }
      description { "Mastering Polish language for travel and cultural understanding" }
      source_language { "ukrainian" }
      target_languages { '["polish"]' }
      learning_context { "Travel and everyday conversations" }
    end

    trait :multilingual do
      name { "Multi Lang" }
      description { "Comprehensive language learning covering multiple target languages" }
      source_language { "ukrainian" }
      target_languages { '["english", "polish"]' }
      learning_context { "Academic and professional communication" }
    end
  end
end
