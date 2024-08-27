# frozen_string_literal: true

namespace :api, defaults: { format: :json } do
  namespace :v1 do
    resources :accounts
    patch 'api_key/rotate', to: 'api_keys#rotate'
  end
end
