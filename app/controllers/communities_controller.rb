class CommunitiesController < ApplicationController
  respond_to :html, :json
  before_action :set_community, only: %i[ show ]
  load_and_authorize_resource

  def index
    respond_to do |format|
      format.html
      format.json {render json: prepare_communities_for_datatable}
    end
  end

  def show
    @type = params[:type]
    respond_to do |format|
      format.html
      format.json {render json: @type == 'incoming_hashtags' || @type == 'outgoing_hashtags' ? prepare_community_hashtags_for_datatable : prepare_community_admins_for_datatable}
    end
  end

  private

    def set_community
      @community = Community.find_by(slug: (params[:community_id].presence || params[:id]))
      raise ActiveRecord::RecordNotFound unless @community
    end

    def prepare_communities_for_datatable
      @all           = Community.all
      @communities   = @all
      
      if @q.present?
        @communities = @communities.where("lower(name) like :q", q: "%#{@q.downcase}%")
      end
      @communities   = @communities.order("#{@sort}": :"#{@dir}").page(@page).per(@per)
      
      @data = @communities.each_with_object([]) { |c, arr| 
        arr << {
          name:   c.name,
          actions: "
                    <a href='#{community_url(c.slug, type: 'community-admin')}' class='btn btn-outline-primary btn-sm'>Admins</a>
                    <a href='#{community_url(c.slug, type: 'incoming_hashtags')}' title='view hashtags' class='btn btn-outline-primary btn-sm'>Communities' hashtags</a>
                    <a href='#{community_url(c.slug, type: 'outgoing_hashtags')}' title='view hashtags' class='btn btn-outline-primary btn-sm'>Posts' hashtags</a>
                    <a href='#{new_community_admin_url(community_id: c.slug, type: 'community-admin')}' class='btn btn-outline-primary btn-sm'>Create community admin</a>
                    <a href='#{new_community_admin_url(community_id: c.slug, type: 'rss-account')}' class='btn btn-outline-primary btn-sm'>Create RSS account</a>
                    <a href='#{community_url(c.slug, type: 'rss-account')}' class='btn btn-outline-primary btn-sm'>RSS accounts</a>
                  "
        }
      }

      total_records  = @all.size
      total_filtered = @q.present? ? @communities.total_count : total_records

      {draw: params[:draw], recordsTotal: total_records, recordsFiltered: total_filtered, data: @data}
    end

    def prepare_community_admins_for_datatable
      @all      = CommunityAdmin.where(community: @community).distinct
      @admins   = @all.joins(user: [:account, :role]).select('mammoth_communities_admins.id, users.email as user_email, 
                                                              user_roles.name as role, accounts.display_name as account_display_name, 
                                                              accounts.username as account_username')
                                                     .where("user_roles.name = '#{@type}'")
      
      if @q.present?
        @admins = @admins.where("
                                  lower(accounts.display_name) LIKE :q
                                  OR lower(accounts.username) LIKE :q
                                  OR lower(users.email) LIKE :q
                                  OR lower(user_roles.name) LIKE :q
                                ", 
                                q: "%#{@q.downcase}%"
                              )
      end
      @admins   = @admins.order("#{@sort}": :"#{@dir}").page(@page).per(@per)
      
      @data = @admins.each_with_object([]) { |c, arr| 
        arr << {
          display_name:   c.account_display_name.presence || '-',
          username:       c.account_username,
          email:          c.user_email,
          role:           c.role,
          actions:        "
                            <a href='#{community_admin_url(c.id)}' title='view admin' class='mr-2'><i class='fa-solid fa-eye'></i></a>
                            <a href='#{edit_community_admin_url(c.id)}' title='edit admin' class='mr-2'><i class='fa-solid fa-user-pen'></i></a>
                          "
          # <a href='#{community_admin_url(c.id)}' title='delete admin' class='mr-2' data-confirm='Are you sure?' rel='nofollow' data-method='delete'><i class='fa-solid fa-trash-can'></i></a>
        }
      }

      total_records  = @all.size
      total_filtered = @q.present? ? @admins.total_count : total_records

      {draw: params[:draw], recordsTotal: total_records, recordsFiltered: total_filtered, data: @data}
    end

    def prepare_community_hashtags_for_datatable
      if @type == 'incoming_hashtags'
        @all      = CommunityHashtag.where(community_id: @community.id, is_incoming: true)
      else
        @all      = CommunityHashtag.where(community_id: @community.id, is_incoming: false)
      end
      @hashtags = @all

      @hashtags = @hashtags.where("hashtag like :q", q: "%#{@q}%") if @q.present?

      @hashtags = @hashtags.order("#{@sort}": :"#{@dir}").page(@page).per(@per)
      
      @data = @hashtags.each_with_object([]) { |h, arr|
        arr << {
          hashtag: h.hashtag,
          actions: "
                    <a href='#{edit_community_hashtag_url(h.id, type: @type)}' title='edit hashtag' class='mr-2'><i class='fa-solid fa-pen-to-square'></i></a>
                    <a href='#{community_hashtag_url(h.id, type: @type)}' title='delete hashtag' class='mr-2' data-confirm='Are you sure?' rel='nofollow' data-method='delete'><i class='fa-solid fa-trash-can'></i></a>
                   "
        }
      }

      total_records  = @all.size
      total_filtered = @q.present? ? @hashtags.total_count : total_records

      {draw: params[:draw], recordsTotal: total_records, recordsFiltered: total_filtered, data: @data}
    end

end