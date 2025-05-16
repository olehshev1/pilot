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

      # Search routes
      get 'search', to: 'search#index'
      get 'search/projects', to: 'search#projects'
      get 'search/tasks', to: 'search#tasks'
    end
  end
end
