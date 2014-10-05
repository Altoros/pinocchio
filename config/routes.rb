Rails.application.routes.draw do
  resources :posts
  root to: 'posts#index'

  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'

  resources :users
  resources :sessions, only: [:new, :create, :destroy]
  resources :password_resets

  namespace :api do
		namespace :v1 do
			resources :posts, format: :json
		end
  end

  mount Rack::API => "/"
end
