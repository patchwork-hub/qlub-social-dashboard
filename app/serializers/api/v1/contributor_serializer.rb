class Api::V1::ContributorSerializer
  include JSONAPI::Serializer

  set_type :account

  attributes :id,
            :username,
            :display_name,
            :note,
            :avatar_url,
            :profile_url,
            :following,
            :is_muted

  attribute :id do |object|
    object.id.to_s
  end

  attribute :profile_url do |object|
    "https://#{object.domain}/@#{object.username}"
  end

  attribute :following do |object, params|
    account_id = params[:account_id]

    follow_ids = Follow.where(account_id: account_id).pluck(:target_account_id)
    follow_request_ids = FollowRequest.where(account_id: account_id).pluck(:target_account_id)

    if follow_ids.include?(object.id)
      'following'
    elsif follow_request_ids.include?(object.id)
      'requested'
    else
      'not_followed'
    end
  end

  attribute :is_muted do |object, params|
    account_id = params[:account_id]

    Mute.where(account_id: account_id, target_account_id: object.id).exists?
  end
end
