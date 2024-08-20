class Filter::Follow < Filter::Common
  def initialize(params)
    super(params)
  end

  def paginated_scope
    Follow.offset((@current_page - 1) * @per_page).limit(@per_page)
  end

  def build_search
    Follow.ransack(@q)
  end
end
