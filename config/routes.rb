Rails.application.routes.draw do
  root to: 'pages#index'

  resources :users, only: [:new, :create, :update]
  resources :leagues, only: [:new, :create, :show, :edit, :update], param: :slug

  get '/dashboard', to: 'users#show', as: 'dashboard'
  get '/edit-profile', to: 'users#edit', as: 'edit_profile'
end
