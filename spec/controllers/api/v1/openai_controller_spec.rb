RSpec.describe Api::V1::OpenaiController, type: :controller do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'POST #chat' do
    let(:valid_params) do
      {
        openai: {
          prompt: 'Tell me a joke',
          model: 'gpt-4o-mini'
        }
      }
    end

    let(:invalid_params) do
      {
        openai: {
          prompt: '',
          model: 'gpt-4o-mini'
        }
      }
    end

    context 'with valid parameters' do
      let(:mock_service) { instance_double(Openai::Chat) }

      before do
        allow(Openai::Chat).to receive(:call).and_return(mock_service)
        allow(mock_service).to receive(:success?).and_return(true)
        allow(mock_service).to receive(:response_text).and_return('Why did the chicken cross the road?')
        allow(mock_service).to receive(:model).and_return('gpt-4o-mini')
      end

      it 'returns successful response' do
        post :chat, params: valid_params

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include(
          'success' => true,
          'response' => 'Why did the chicken cross the road?',
          'model' => 'gpt-4o-mini'
        )
      end

      it 'calls the OpenAI service with correct parameters' do
        expect(Openai::Chat).to receive(:call).with('Tell me a joke', model: 'gpt-4o-mini')
        post :chat, params: valid_params
      end
    end

    context 'with invalid parameters' do
      let(:mock_service) { instance_double(Openai::Chat) }

      before do
        allow(Openai::Chat).to receive(:call).and_return(mock_service)
        allow(mock_service).to receive(:success?).and_return(false)
        allow(mock_service).to receive(:errors).and_return([ 'Prompt cannot be blank' ])
        allow(mock_service).to receive(:status_error).and_return(:service_unavailable)
      end

      it 'returns error response' do
        post :chat, params: invalid_params

        expect(response).to have_http_status(:service_unavailable)
        expect(JSON.parse(response.body)).to include(
          'success' => false,
          'errors' => [ 'Prompt cannot be blank' ]
        )
      end
    end

    context 'when user is not authenticated' do
      before do
        sign_out user
      end

      it 'returns unauthorized' do
        post :chat, params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with default model' do
      let(:params_without_model) do
        {
          openai: {
            prompt: 'Tell me a joke'
          }
        }
      end

      let(:mock_service) { instance_double(Openai::Chat) }

      before do
        allow(Openai::Chat).to receive(:call).and_return(mock_service)
        allow(mock_service).to receive(:success?).and_return(true)
        allow(mock_service).to receive(:response_text).and_return('A joke')
        allow(mock_service).to receive(:model).and_return('gpt-4o-mini')
      end

      it 'uses default model when not specified' do
        expect(Openai::Chat).to receive(:call).with('Tell me a joke', model: 'gpt-4o-mini')
        post :chat, params: params_without_model
      end
    end
  end
end
