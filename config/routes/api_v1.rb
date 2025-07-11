# frozen_string_literal: true

namespace :api, defaults: { format: :json } do
  namespace :v1 do
    resources :accounts

    patch 'api_key/rotate', to: 'api_keys#rotate'
    get 'custom_menus/display', to: proc { [200, { 'Content-Type' => 'application/json' }, [{ display: true }.to_json]] }

    namespace :debug do
       post :queries,  to: 'debug#queries' if Rails.env.development?
    end

    resources :channels, only: [] do
      collection do
        get :recommend_channels
        get :group_recommended_channels
        get :search
        get :channel_detail
        get :my_channel
        get :channel_feeds
        get :newsmast_channels
        get :bridge_information
      end
    end

    resources :search, only: [] do
      collection do
         post '/', to: 'search#search'
      end
    end

    resources :wait_list, only: [ :create ] do
      collection do
        post :request_invitation_code
        get :validate_code
      end
    end

    resources :collections, only: [ :index ] do
      collection do
        get :fetch_channels
        get :newsmast_collections
        get :channel_feed_collections
      end
    end

    resources :community_admins, only: %i[index show update] do
      collection do
        get :boost_bot_accounts
        post :modify_account_status
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
        get 'fetch_ip_address'
      end
      member do
        patch :manage_additional_information
        put :manage_additional_information
      end
      resources :community_filter_keywords, only: %i[index create update destroy]
      resources :community_hashtags, only: %i[index create update destroy]
      resources :community_post_types, only: [:index, :create]
    end

    resources :content_types, only: [:index, :create]

    resources :joined_communities, only: %i[index create destroy] do
      collection do
        post :set_primary
      end
    end

    get '/domains/verify', to: 'domains#verify'
    get 'general_icons', to: 'community_links#general'
    get 'social_icons',  to: 'community_links#social'

    resources :app_versions,only: [] do 
      collection do
        get 'check_version' => 'app_versions#check_version', as: 'check_version'
      end
    end

    resources :settings,only: [:index, :destroy] do
      collection do
        post :upsert
      end
    end
  end
end

