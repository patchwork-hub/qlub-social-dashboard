# frozen_string_literal: true

class BaseService
  include ActionView::Helpers::SanitizeHelper

  def call(*)
    raise NotImplementedError
  end
end
