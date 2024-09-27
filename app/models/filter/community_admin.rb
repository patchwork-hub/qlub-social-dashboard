class Filter::CommunityAdmin < Filter::Common
  def initialize(params)
    super(params)
    @q = params[:q] || {}
    @current_page = params[:page] || 1
    @per_page = 10
  end

  def paginated_scope
    build_search.result.page(@current_page).per(@per_page)
  end

  def build_search
    CommunityAdmin.ransack(@q)
  end

  def get
    paginated_scope
  end
end
