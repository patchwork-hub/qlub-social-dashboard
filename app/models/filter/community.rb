class Filter::Community < Filter::Common
  def initialize(params, current_user)
    @current_user = current_user
    super(params)
    @q = params[:q] || {}
    @current_page = params[:page] || 1
    @per_page = 10
  end

  def get
    paginated_scope
  end

  def paginated_scope
    build_search.result.order(id: :desc).page(@current_page).per(@per_page)
  end

  def build_search
    if master_admin?
      Community.ransack(@q)
    else
      Community.joins(:community_admins)
               .where(community_admins: { account_id: account_id })
               .ransack(@q)
    end
  end

  def master_admin?
    @current_user&.role&.name.in?(%w[MasterAdmin])
  end

  def account_id
    @current_user.account_id
  end
end
