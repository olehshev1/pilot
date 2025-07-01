FactoryBot.define do
  factory :task do
    name { "Sample Task" }
    description { "This is a sample task description" }
    status { "not_started" }
    original_word { "word" }
    translations { '{"english": ["word"], "polish": ["słowo"]}' }
    examples { '{"english": {"examples": []}, "polish": {"examples": []}}' }
    learning_status { "new" }
    association :project

    trait :in_progress do
      status { "in_progress" }
      learning_status { "learning" }
    end

    trait :completed do
      status { "completed" }
      learning_status { "mastered" }
    end

    trait :word_translation do
      name { "house → дім | dom" }
      description { "Ukrainian: дім\nPolish: dom, mieszkanie\n\nPart of speech: noun | Difficulty: beginner" }
      original_word { "house" }
      translations { '{"ukrainian": ["дім"], "polish": ["dom", "mieszkanie"]}' }
      examples do
        {
          "ukrainian" => {
            "examples" => [
              {
                "translation" => "дім",
                "sentences" => [
                  {
                    "sentence" => "Це мій дім.",
                    "translation_back" => "This is my house.",
                    "context" => "daily",
                    "difficulty" => "beginner"
                  }
                ]
              }
            ],
            "learning_tips" => [ "Дім is the most common word for house in Ukrainian" ]
          },
          "polish" => {
            "examples" => [
              {
                "translation" => "dom",
                "sentences" => [
                  {
                    "sentence" => "To jest mój dom.",
                    "translation_back" => "This is my house.",
                    "context" => "daily",
                    "difficulty" => "beginner"
                  }
                ]
              }
            ],
            "learning_tips" => [ "Dom is the most common word for house in Polish" ]
          }
        }.to_json
      end
      learning_status { "learning" }
    end

    trait :advanced_word do
      name { "complex → складний | złożony" }
      description { "Ukrainian: складний\nPolish: złożony, skomplikowany\n\nPart of speech: adjective | Difficulty: intermediate" }
      original_word { "complex" }
      translations { '{"ukrainian": ["складний"], "polish": ["złożony", "skomplikowany"]}' }
      learning_status { "practiced" }
    end

    trait :no_translation do
      original_word { nil }
      translations { '{}' }
      examples { '{}' }
    end
  end
end
