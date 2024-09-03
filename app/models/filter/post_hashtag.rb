class Filter::PostHashtag < Filter::Common
  def initialize(params)
    super(params)
  end

  def paginated_scope
    PostHashtag.offset((@current_page - 1) * @per_page).limit(@per_page)
  end

  def build_search
    PostHashtag.ransack(@q)
  end
end
