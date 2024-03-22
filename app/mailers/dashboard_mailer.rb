class DashboardMailer < ActionMailer::Base
  default from: %{Newsmast <#{ENV['SMTP_FROM_ADDRESS']}>}
  layout "mailer"

  def invitation_codes_report(args={})
    @download_link = args[:download_link]
    @role          = args[:role]
    @limit         = args[:limit]
    @email         = args[:email]
    @type          = args[:type]
    if @type == 'new_invitation_code'
      @subject       = "Newsmast: #{@limit} #{@role.capitalize} Invitation Codes Report #{Time.zone.now.strftime('%Y-%m-%d')}"
    elsif @type == 'existing_invitation_code'
      @subject       = "Newsmast: Existing Invitation Codes Report #{Time.zone.now.strftime('%Y-%m-%d')}"
    end
    
    mail(to: @email, subject: @subject)
  end

  def users_report(args={})
    @download_link = args[:download_link]
    @email         = args[:email]
    @subject       = "Newsmast: Users Report #{Time.zone.now.strftime('%Y-%m-%d')}"
    
    mail(to: @email, subject: @subject)
  end
end
