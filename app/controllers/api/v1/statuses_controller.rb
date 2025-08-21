module Api::V1
  class StatusesController < ApiController
    before_action :whitelist_domains

    def boost_post
      @api_base_url = ENV.fetch('MASTODON_INSTANCE_URL')

      unless params[:post_url].present? && params[:boost_post_username].present? && params[:boost_post_user_domain].present?
        return render_error("Missing post_url or boost_post_username or boost_post_user_domain", :unprocessable_entity)
      end

      @token = fetch_oauth_token(params[:boost_post_username], params[:boost_post_user_domain])
      return render_error("Could not generate OAuth token for #{params[:boost_post_username]}@#{params[:boost_post_user_domain]}", :unauthorized) unless @token.present?

      post_id = SearchPostService.new(@api_base_url, @token, params[:post_url]).call
      return render_error("Post not found or invalid post URL", :not_found) unless post_id.present?

      result = ReblogPostService.new(@token, post_id).call
      render json: result
    end

    private

    def whitelist_domains
      allowed_domains = ["mo-me.social"]

      unless allowed_domains.include?(request.host)
        render_error("Request domain not allowed", :forbidden)
      end
    end

    def fetch_oauth_token(username, domain)
      admin = Account.find_by(username: username, domain: domain)
      return nil unless admin&.user

      GenerateAdminAccessTokenService.new(admin.user.id).call
    rescue => e
      nil
    end

    def render_error(message, status)
      render json: {
        status: status,
        body: message
      }
    end
  end
end
