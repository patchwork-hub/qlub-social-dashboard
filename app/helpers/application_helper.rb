module ApplicationHelper
    def url_for_page(page)
        url_for(request.params.merge(page: page))
    end
end
