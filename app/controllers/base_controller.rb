class BaseController < ApplicationController
  load_and_authorize_resource

  def index
    @records = load_records
    @search = records_filter.build_search
  end

  def load_records
    records_filter.get
  end

  def records_filter
    raise NotImplementedError, "Subclasses must implement the `records_filter`."
  end
end
