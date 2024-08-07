class Filter::Common
  DEFAULT_ITEMS_LIMIT = 25
  attr_reader :current_page, :total_pages, :per_page, :search

  def initialize(params)
    @q = params[:q]
    @current_page = params[:page].to_i > 0 ? params[:page].to_i : 1
    @per_page = DEFAULT_ITEMS_LIMIT
    @total_pages = (public_scope.count.to_f / DEFAULT_ITEMS_LIMIT).ceil
  end

  def get
    scope = public_scope
    scope.merge!(paginated_scope) 
  end

  def paginated_scope
    raise NotImplementedError, "Subclasses must implement the `paginated scope`."
  end

  def prev_page
    @current_page > 1 ? @current_page - 1 : 1
  end

  def next_page
    @current_page < @total_pages ? @current_page + 1 : nil
  end

  def bulid_search
    raise NotImplementedError, "Subclasses must implement the `build_search`."
  end

  def public_scope
    bulid_search.result
  end

  def display_page
    if @current_page < 3
      @current_page
    else
      @current_page - 2
    end
  end

  def each_page
    (display_page..@total_pages).map do |page|
      OpenStruct.new(number: page, current?: page == current_page)
    end
  end
end
  