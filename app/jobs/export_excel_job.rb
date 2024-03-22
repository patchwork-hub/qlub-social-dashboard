# frozen_string_literal: true
require 'aws-sdk-s3'

class ExportExcelJob < ApplicationJob
  queue_as :default

  def perform(args={})
    @args       = args
    @type       = @args[:type]
    @email      = @args[:email]
    @datestring = Time.zone.now.strftime('%Y-%m-%d-%H-%M-%S')

    case @type
    when 'new_invitation_code'
      generate_new_invitation_codes
    when 'existing_invitation_code'
      generate_existing_invitation_codes
    when 'user'
      generate_users
    end

    if @filepath.present?
      s3_upload
      send_email
    end
  end

  private

  def generate_new_invitation_codes
    @role       = @args[:role]
    @limit      = @args[:limit]

    @s3_path    = "dashboard/exported_reports/invitation_codes/new/#{@role}-#{@limit}-#{@datestring}.xlsx"
    @filename   = "#{@limit}-#{@role.capitalize}-Newsmast-New-Invitation-Codes-#{@datestring}.xlsx"
    @action     = :invitation_codes_report

    if @role.present?
      @filepath   = WaitList.export_codes(role: @role, limit: @limit.to_i)
    end
  end

  def generate_existing_invitation_codes
    @selected   = @args[:selected]
    @unselected = @args[:unselected]
    @q          = @args[:q]

    @s3_path    = "dashboard/exported_reports/invitation_codes/existing/invitation_codes-#{@datestring}.xlsx"
    @filename   = "Newsmast-Existing-Invitation-Codes-#{@datestring}.xlsx"
    @action     = :invitation_codes_report
    
    @filepath = WaitList.to_xlsx(q: @q, selected: @selected, unselected: @unselected)
  end

  def generate_users
    @selected   = @args[:selected]
    @unselected = @args[:unselected]
    @q          = @args[:q]
    
    @s3_path    = "dashboard/exported_reports/users/users-list-#{@datestring}.xlsx"
    @filename   = "Newsmast-Users-List-#{@datestring}.xlsx"
    @action     = :users_report

    @filepath   = Account.to_xlsx(q: @q, selected: @selected, unselected: @unselected)
  end

  def send_email
    DashboardMailer.send(@action, email: @email, download_link: @download_link, role: @role, limit: @limit, type: @type).deliver_now
  end

  def s3
    @s3 ||= Aws::S3::Resource.new(
      region: ENV['S3_REGION'],
      access_key_id: ENV['S3_KEY'],
      secret_access_key: ENV['S3_SECRET']
    )
  end

  def s3_bucket
    bucket = s3.bucket(ENV['S3_BUCKET'])
  end

  def s3_upload
    xlsx   = File.open("#{Rails.root}/#{@filepath}")

    object = s3_bucket.object(@s3_path)
    object.put(body: xlsx)

    @download_link = object.presigned_url(:get_object,
                                            response_content_disposition: "attachment; filename=\"#{@filename}\"", 
                                            expires_in: 604800
                                         ).to_s
  end
end
