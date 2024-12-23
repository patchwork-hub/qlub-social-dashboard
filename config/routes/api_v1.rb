# frozen_string_literal: true

namespace :api, defaults: { format: :json } do
  namespace :v1 do
    resources :accounts
    patch 'api_key/rotate', to: 'api_keys#rotate'

    resources :channels, only: [  ] do
      collection do
        get :recommend_channels
        get :group_recommended_channels
        get :search
        get :channel_detail
        get :my_channel
      end
    end

    resources :collections, only: [ :index ] do
      collection do
        get :fetch_channels
      end
    end

    resources :sessions, only: [] do
      collection do
        post :log_out
      end
    end

    resources :community_admins, only: [] do
      collection do
        get :boost_bot_accounts
      end
    end

  end
end
