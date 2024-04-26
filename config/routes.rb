Rails.application.routes.draw do

  authenticate :user, lambda { |u| u.owner? } do
    mount Sidekiq::Web, at: 'sidekiq', as: :sidekiq
  end

  root "app_versions#index"

  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  health_check_routes

  resources :wait_lists, only: %i[ index show create ]
  get '/invitation_codes', to: 'wait_lists#invitation_codes', as: :invitation_codes
  get 'invitation_code_list', to: 'wait_lists#invitation_code_list', as: :invitation_code_list
  get '/invitation_codes/:id', to: 'wait_lists#invitation_code', as: :invitation_code
  match '/invitation_codes/export/new', to: 'wait_lists#export', as: :export_invitation_codes, via: [:get, :post]

  resources :communities, only: %i[ index show ]
  resources :community_admins
  resources :community_hashtags
  resources :reports, only: %i[ index show ]
  resources :accounts, only: %i[ index show ] do
    collection do
      match :export, via: [:get, :post]
    end
  end
  resources :app_versions
  put "history/:id/deprecate", to: 'app_versions#deprecate'
  resources :global_filters
  get '/timelines_status', to: 'timelines_status#index'

  resources :server_settings, only: [:index, :new, :create, :edit, :update, :destroy]
  get '/get_child_count', to: 'server_settings#get_child_count'

  resources :keyword_filters
end
