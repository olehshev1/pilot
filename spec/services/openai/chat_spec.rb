RSpec.describe Openai::Chat do
  let(:prompt) { 'Tell me a joke' }
  let(:model) { 'gpt-4o-mini' }
  let(:service) { described_class.new(prompt, model: model) }
  let(:mock_client) { instance_double(OpenAI::Client) }

  before do
    allow(Rails.application.credentials).to receive(:openai).and_return({ api_key: 'test_key' })
    allow(OpenAI::Client).to receive(:new).and_return(mock_client)
  end

  describe '#initialize' do
    it 'sets the prompt and model' do
      expect(service.prompt).to eq(prompt)
      expect(service.model).to eq(model)
      expect(service.errors).to be_empty
      expect(service.response_text).to be_nil
    end

    it 'uses default model when not specified' do
      default_service = described_class.new(prompt)
      expect(default_service.model).to eq('gpt-4o-mini')
    end
  end

  describe '#call' do
    context 'with valid prompt' do
      let(:openai_response) do
        {
          'choices' => [
            {
              'message' => {
                'content' => 'Why did the chicken cross the road? To get to the other side!'
              }
            }
          ]
        }
      end

      before do
        allow(mock_client).to receive(:chat).and_return(openai_response)
      end

      it 'makes a request to OpenAI' do
        expect(mock_client).to receive(:chat).with(
          parameters: {
            model: 'gpt-4o-mini',
            messages: [ { role: 'user', content: prompt } ],
            temperature: 0.7,
            max_tokens: 500
          }
        )

        service.call
      end

      it 'returns success' do
        result = service.call
        expect(result.success?).to be_truthy
      end

      it 'sets response_text' do
        result = service.call
        expect(result.response_text).to eq('Why did the chicken cross the road? To get to the other side!')
      end
    end

    context 'with blank prompt' do
      let(:service) { described_class.new('') }

      it 'returns early without making API call' do
        expect(mock_client).not_to receive(:chat)
        result = service.call
        expect(result).to eq(service)
      end
    end

    context 'when OpenAI returns no content' do
      before do
        allow(mock_client).to receive(:chat).and_return({ 'choices' => [ { 'message' => { 'content' => nil } } ] })
      end

      it 'adds error for no response' do
        result = service.call
        expect(result.success?).to be_falsey
        expect(result.errors).to include('No response received from OpenAI')
      end
    end

    context 'when API request fails' do
      before do
        allow(mock_client).to receive(:chat).and_raise(Faraday::ConnectionFailed.new('Connection failed'))
      end

      it 'handles the error gracefully' do
        result = service.call
        expect(result.success?).to be_falsey
        expect(result.errors).to include('Failed to communicate with OpenAI: Connection failed')
      end

      it 'returns service_unavailable status' do
        result = service.call
        expect(result.status_error).to eq(:service_unavailable)
      end
    end

    context 'when unexpected error occurs' do
      before do
        allow(mock_client).to receive(:chat).and_raise(StandardError.new('Unexpected error'))
      end

      it 'handles the error gracefully' do
        result = service.call
        expect(result.success?).to be_falsey
        expect(result.errors).to include('An unexpected error occurred: Unexpected error')
      end
    end
  end

  describe '#success?' do
    it 'returns true when no errors and response_text present' do
      service.instance_variable_set(:@errors, [])
      service.instance_variable_set(:@response_text, 'Some response')
      expect(service.success?).to be_truthy
    end

    it 'returns false when errors present' do
      service.instance_variable_set(:@errors, [ 'Some error' ])
      service.instance_variable_set(:@response_text, 'Some response')
      expect(service.success?).to be_falsey
    end

    it 'returns false when response_text blank' do
      service.instance_variable_set(:@errors, [])
      service.instance_variable_set(:@response_text, nil)
      expect(service.success?).to be_falsey
    end
  end
end
