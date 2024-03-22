class BanStatusJob < ApplicationJob
  queue_as :ban_status

  def perform(args={})
    @args = args

    if @args[:filter_id].present?
      unban_statuses if @args[:flag] == 'updated'
      @filter  = GlobalFilter.find(@args[:filter_id])
      
      if @args[:is_hashtag]
        @tag = Tag.find_by(name: @filter.keyword.downcase.gsub('#', ''))
        ban_statuses(@tag.statuses) if @tag
      else
        Status.where("LOWER(text) ~* ?", "\\m#{@filter.keyword.downcase}\\M").find_in_batches(batch_size: 100, order: :desc) do |statuses|
          ban_statuses(statuses)
        end
      end

    end
  end

  private
    
    def ban_statuses(statuses = [])
      array = statuses.map{|status| {status_id: status.id, community_filter_keyword_id: @filter.id}}
      BanStatus.create(array)
    end

    def unban_statuses
      BanStatus.where(community_filter_keyword_id: @args[:filter_id]).destroy_all
    end

end