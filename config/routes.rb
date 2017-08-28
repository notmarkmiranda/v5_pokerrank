Rails.application.routes.draw do
  root to: 'pages#index'

  resources :users, only: [:create, :update]
  resources :leagues, only: [:new, :create, :show, :edit, :update], param: :slug do
    scope module: :leagues do
      resources :seasons, except: [:destroy] do
        scope module: :seasons do
          resources :games, except: [:destroy]
        end
      end
    end
  end
  resources :participants
  resources :players

  get 'sign-up', to: 'users#new', as: 'sign_up'
  get 'sign-in', to: 'sessions#new', as: 'sign_in'
  post 'sign-in', to: 'sessions#create'
  get 'sign-out', to: 'sessions#destroy', as: 'sign_out'

  get '/dashboard', to: 'users#show', as: 'dashboard'
  get '/edit-profile', to: 'users#edit', as: 'edit_profile'
  get '/not-found', to: 'pages#not_found', as: 'not_found'
end
