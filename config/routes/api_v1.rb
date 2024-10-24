# frozen_string_literal: true

namespace :api, defaults: { format: :json } do
  namespace :v1 do
    resources :accounts
    patch 'api_key/rotate', to: 'api_keys#rotate'
    
    resources :channels, only: %i[ index ] do
      collection do
        get :recommend_channels
        get :group_recommended_channels
      end
    end

    resources :collections, only: %i[ index show]
  end
end
