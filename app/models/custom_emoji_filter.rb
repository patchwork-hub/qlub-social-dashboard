# frozen_string_literal: true

class CustomEmojiFilter
  KEYS = %i(
    local
    remote
    by_domain
    shortcode
  ).freeze

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    scope = CustomEmoji.alphabetic

    params.each do |key, value|
      next if key.to_s == 'page'
      next if key.to_s == 'filter'
      next if key.to_s == 'search'

      scope.merge!(scope_for(key, value)) if value.present?
    end

    # Handle the filter parameter
    if params[:filter].present?
      case params[:filter]
      when 'local'
        scope = scope.merge(CustomEmoji.local.left_joins(:category).reorder(CustomEmojiCategory.arel_table[:name].asc.nulls_first).order(shortcode: :asc))
      when 'remote'
        scope = scope.merge(CustomEmoji.remote)
      end
    end

    # Handle the search parameter
    if params[:search].present?
      search_term = params[:search].strip
      scope = scope.where(
        CustomEmoji.arel_table[:shortcode].matches("%#{search_term}%")
        .or(CustomEmoji.arel_table[:domain].matches("%#{search_term}%"))
      )
    end

    scope
  end

  private

  def scope_for(key, value)
    case key.to_s
    when 'local'
      CustomEmoji.local.left_joins(:category).reorder(CustomEmojiCategory.arel_table[:name].asc.nulls_first).order(shortcode: :asc)
    when 'remote'
      CustomEmoji.remote
    when 'by_domain'
      CustomEmoji.where(domain: value.strip.downcase)
    when 'shortcode'
      CustomEmoji.search(value.strip)
    else
      raise Mastodon::InvalidParameterError, "Unknown filter: #{key}"
    end
  end
end
