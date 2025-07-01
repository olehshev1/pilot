require 'rails_helper'

RSpec.describe LanguageLearning::Translator do
  include LanguageLearningHelpers

  let(:word) { 'house' }
  let(:source_language) { 'english' }
  let(:target_languages) { %w[ukrainian polish] }
  let(:context) { 'Architecture and buildings' }
  let(:service) { described_class.new(word, source_language, target_languages, context: context) }
  let(:mock_client) { setup_openai_mocks }

  describe '#initialize' do
    it 'sets the word and languages correctly' do
      expect(service.word).to eq('house')
      expect(service.source_language).to eq('english')
      expect(service.target_languages).to eq(%w[ukrainian polish])
      expect(service.context).to eq('Architecture and buildings')
    end

    it 'handles array target languages' do
      service = described_class.new(word, source_language, 'ukrainian')
      expect(service.target_languages).to eq([ 'ukrainian' ])
    end

    it 'strips whitespace from inputs' do
      service = described_class.new(' test ', ' english ', [ ' ukrainian ' ], context: ' context ')
      expect(service.word).to eq('test')
      expect(service.source_language).to eq('english')
      expect(service.target_languages).to eq([ 'ukrainian' ])
      expect(service.context).to eq('context')
    end
  end

  describe '#call' do
    context 'with valid inputs' do
      let(:mock_response) do
        mock_translation_response(
          {
            'ukrainian' => [ 'дім', 'будинок' ],
            'polish' => [ 'dom', 'mieszkanie' ]
          },
          {
            'part_of_speech' => 'noun',
            'difficulty' => 'beginner'
          }
        )
      end

      before do
        allow(mock_client).to receive(:chat).and_return(mock_response)
      end

      it 'makes successful translation request' do
        result = service.call

        expect(result).to eq(service)
        expect(service.success?).to be true
        expect(service.translations).to eq({
          'ukrainian' => [ 'дім', 'будинок' ],
          'polish' => [ 'dom', 'mieszkanie' ]
        })
      end

      it 'calls OpenAI with correct parameters' do
        expect(mock_client).to receive(:chat).with(
          parameters: {
            model: 'gpt-4o-mini',
            messages: [ { role: 'user', content: anything } ],
            temperature: 0.3,
            max_tokens: 800
          }
        )

        service.call
      end

      it 'includes context in the prompt' do
        expected_prompt_content = /Architecture and buildings/

        expect(mock_client).to receive(:chat) do |params|
          expect(params[:parameters][:messages].first[:content]).to match(expected_prompt_content)
          mock_response
        end

        service.call
      end
    end

    context 'with blank word' do
      let(:word) { '' }

      it 'returns early without making API call' do
        expect(mock_client).not_to receive(:chat)

        result = service.call
        expect(result).to eq(service)
        expect(service.success?).to be false
      end
    end

    context 'with unsupported language' do
      let(:target_languages) { %w[french] }

      it 'returns early with validation error' do
        expect(mock_client).not_to receive(:chat)

        result = service.call
        expect(result).to eq(service)
        expect(service.success?).to be false
        expect(service.errors).to include(/Unsupported language: french/)
      end
    end

    context 'when OpenAI returns no content' do
      before do
        allow(mock_client).to receive(:chat).and_return(mock_empty_response)
      end

      it 'adds appropriate error' do
        service.call

        expect(service.success?).to be false
        expect(service.errors).to include('No translation received from OpenAI')
      end
    end

    context 'when OpenAI returns invalid JSON' do
      before do
        allow(mock_client).to receive(:chat).and_return(mock_invalid_json_response)
        allow(Rails.logger).to receive(:error)
      end

      it 'handles JSON parsing error gracefully' do
        service.call

        expect(service.success?).to be false
        expect(service.errors).to include('Invalid translation response format')
      end
    end

    context 'when API request fails' do
      before do
        allow(mock_client).to receive(:chat).and_raise(Faraday::Error.new('Connection failed'))
        allow(Rails.logger).to receive(:error)
      end

      it 'handles API errors gracefully' do
        service.call

        expect(service.success?).to be false
        expect(service.errors).to include(/Failed to communicate with OpenAI/)
      end
    end
  end

  describe '#success?' do
    it 'returns true when no errors and translations present' do
      service.instance_variable_set(:@errors, [])
      service.instance_variable_set(:@translations, { 'ukrainian' => [ 'дім' ] })

      expect(service.success?).to be true
    end

    it 'returns false when errors present' do
      service.instance_variable_set(:@errors, [ 'Some error' ])
      service.instance_variable_set(:@translations, { 'ukrainian' => [ 'дім' ] })

      expect(service.success?).to be false
    end

    it 'returns false when no translations' do
      service.instance_variable_set(:@errors, [])
      service.instance_variable_set(:@translations, {})

      expect(service.success?).to be false
    end
  end
end
