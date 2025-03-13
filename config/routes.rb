Rails.application.routes.draw do
  devise_for :users

  namespace :api do
    namespace :v1 do
      resources :users, only: [ :create ]
      post 'sign_in', to: 'sessions#create'
      get 'me', to: 'users#me'
    end
  end
end
