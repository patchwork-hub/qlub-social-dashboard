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

    resources :community_admins, only: %i[index show update] do
      collection do
        get :boost_bot_accounts
      end
    end

    resources :communities, path: 'channels' do
      collection do
        get 'community_types'
        get 'collections'
        get 'contributor_list'
        get 'search_contributor'
        get 'mute_contributor_list'
        post 'set_visibility'
      end
      resources :community_filter_keywords, only: %i[index create update destroy]
      resources :community_hashtags, only: %i[index create update destroy]
      resources :community_post_types, only: [:index, :create]
    end

    resources :content_types, only: [:index, :create]
  end
end
