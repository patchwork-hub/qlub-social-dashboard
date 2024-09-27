class DashboardMailer < ActionMailer::Base
  default from: %{Patchwork <#{ENV['SMTP_FROM_ADDRESS']}>}
  layout "mailer"

  def channel_created(community, admin_emails)
    @community = community
    mail(to: admin_emails, subject: 'New Channel Created')
  end
end
