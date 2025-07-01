module LanguageLearningHelpers
  # Shared setup for OpenAI mocking
  def setup_openai_mocks
    allow(Rails.application.credentials).to receive(:openai).and_return({ api_key: 'test_key' })
    mock_client = instance_double(OpenAI::Client)
    allow(OpenAI::Client).to receive(:new).and_return(mock_client)
    mock_client
  end

  # Create mock OpenAI response for translation
  def mock_translation_response(translations, word_info = {})
    {
      'choices' => [ {
        'message' => {
          'content' => {
            'translations' => translations,
            'word_info' => word_info
          }.to_json
        }
      } ]
    }
  end

  # Create mock OpenAI response for examples
  def mock_examples_response(examples, learning_tips = [])
    {
      'choices' => [ {
        'message' => {
          'content' => {
            'examples' => examples,
            'learning_tips' => learning_tips
          }.to_json
        }
      } ]
    }
  end

  # Create empty/invalid OpenAI response
  def mock_empty_response
    {
      'choices' => [ {
        'message' => {
          'content' => nil
        }
      } ]
    }
  end

  # Create invalid JSON response
  def mock_invalid_json_response
    {
      'choices' => [ {
        'message' => {
          'content' => 'invalid json response'
        }
      } ]
    }
  end
end
