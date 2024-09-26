class Filter::Community < Filter::Common
  def initialize(params)
    super(params)
    @q = params[:q] || {}
    @current_page = params[:page] || 1
    @per_page = 10
  end

  def paginated_scope
    build_search.result.order(id: :desc).page(@current_page).per(@per_page)
  end

  def build_search
    Community.ransack(@q)
  end

  def get
    paginated_scope
  end
end
