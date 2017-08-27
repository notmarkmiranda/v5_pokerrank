Rails.application.routes.draw do
  root to: 'pages#index'

  resources :users, only: [:new, :create, :update]
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

  get '/dashboard', to: 'users#show', as: 'dashboard'
  get '/edit-profile', to: 'users#edit', as: 'edit_profile'
end
