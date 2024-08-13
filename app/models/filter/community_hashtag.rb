class Filter::CommunityHashtag < Filter::Common
  def initialize(params)
    super(params)
  end

  def paginated_scope
    CommunityHashtag.offset((@current_page - 1) * @per_page).limit(@per_page)
  end

  def build_search
    CommunityHashtag.ransack(@q)
  end
end
