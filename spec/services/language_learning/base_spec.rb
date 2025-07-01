RSpec.describe LanguageLearning::Base do
  let(:service) { described_class.new }

  before do
    allow(Rails.application.credentials).to receive(:openai).and_return({ api_key: 'test_key' })
    service.instance_variable_set(:@errors, [])
  end

  describe 'constants' do
    it 'defines supported languages' do
      expect(described_class::SUPPORTED_LANGUAGES).to eq(%w[ukrainian english polish])
    end

    it 'defines language names mapping' do
      expected_mapping = {
        'ukrainian' => 'Ukrainian',
        'english' => 'English',
        'polish' => 'Polish'
      }
      expect(described_class::LANGUAGE_NAMES).to eq(expected_mapping)
    end
  end

  describe '#language_name' do
    it 'returns proper language name for supported languages' do
      expect(service.send(:language_name, 'ukrainian')).to eq('Ukrainian')
      expect(service.send(:language_name, 'english')).to eq('English')
      expect(service.send(:language_name, 'polish')).to eq('Polish')
    end

    it 'capitalizes unknown language codes' do
      expect(service.send(:language_name, 'french')).to eq('French')
    end
  end

  describe '#validate_language' do
    it 'returns true for supported languages' do
      expect(service.send(:validate_language, 'ukrainian')).to be true
      expect(service.send(:validate_language, 'english')).to be true
      expect(service.send(:validate_language, 'polish')).to be true
    end

    it 'returns false and adds error for unsupported languages' do
      result = service.send(:validate_language, 'french')

      expect(result).to be false
      expect(service.instance_variable_get(:@errors)).to include(
        'Unsupported language: french. Supported: ukrainian, english, polish'
      )
    end
  end

  describe '#validate_languages' do
    it 'returns true when all languages are supported' do
      result = service.send(:validate_languages, %w[ukrainian english polish])
      expect(result).to be true
    end

    it 'returns false when any language is unsupported' do
      result = service.send(:validate_languages, %w[ukrainian french])
      expect(result).to be false
    end
  end

  describe '#safe_json_parse' do
    it 'parses valid JSON' do
      json_text = '{"key": "value"}'
      result = service.send(:safe_json_parse, json_text)
      expect(result).to eq({ 'key' => 'value' })
    end

    it 'extracts JSON from text with additional content' do
      text_with_json = 'Some text before {"key": "value"} some text after'
      result = service.send(:safe_json_parse, text_with_json)
      expect(result).to eq({ 'key' => 'value' })
    end

    it 'returns nil for invalid JSON and logs error' do
      expect(Rails.logger).to receive(:error).with(/JSON Parse Error/)

      result = service.send(:safe_json_parse, 'invalid json')
      expect(result).to be_nil
    end
  end

  describe '#structured_response_prompt' do
    it 'returns structured prompt instruction' do
      prompt = service.send(:structured_response_prompt)
      expect(prompt).to include('Please respond with a valid JSON object only')
    end
  end
end
