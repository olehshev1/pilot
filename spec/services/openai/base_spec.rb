RSpec.describe Openai::Base do
  describe '.call' do
    it 'can be called and returns instance' do
      allow(Rails.application.credentials).to receive(:openai).and_return({ api_key: 'test_key' })

      result = described_class.call
      expect(result).to be_an_instance_of(described_class)
    end
  end

  describe '#call' do
    it 'returns self when called' do
      allow(Rails.application.credentials).to receive(:openai).and_return({ api_key: 'test_key' })

      service = described_class.new
      result = service.call
      expect(result).to eq(service)
    end
  end

  describe '#openai_client' do
    let(:service) { described_class.new }

    it 'returns an OpenAI client instance' do
      allow(Rails.application.credentials).to receive(:openai).and_return({ api_key: 'test_key' })

      client = service.send(:openai_client)
      expect(client).to be_an_instance_of(OpenAI::Client)
    end
  end

  describe '#handle_openai_error' do
    let(:service) { described_class.new }
    let(:error) { StandardError.new('Test error') }

    before do
      service.instance_variable_set(:@errors, [])
    end

    it 'logs the error and adds it to errors array' do
      expect(Rails.logger).to receive(:error).with('OpenAI API Error: Test error')

      service.send(:handle_openai_error, error)

      expect(service.instance_variable_get(:@errors)).to include('Failed to communicate with OpenAI: Test error')
    end
  end
end
