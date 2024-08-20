class Filter::Community < Filter::Common

  def initialize(params)
    super(params)
  end

  def paginated_scope
    Community.offset((@current_page - 1) * @per_page).limit(@per_page)
  end

  def build_search
    Community.ransack(@q)
  end
end
