Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  devise_for :users

  namespace :api do
    namespace :v1 do
      resources :users, only: [ :create ]
      post 'sign_in', to: 'sessions#create'
      get 'me', to: 'users#me'
      resources :projects do
        resources :tasks
      end

      # OpenAI endpoints
      namespace :openai do
        post :chat
      end

      # Language Learning endpoints
      namespace :language_learning do
        post :translate_word
        post :create_word_task
        get :word_details, path: 'word_details/:id'
        patch :advance_learning, path: 'advance_learning/:id'
      end
    end
  end
end
