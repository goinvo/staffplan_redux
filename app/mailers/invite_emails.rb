class InviteEmails < ActionMailer::Base
  default from: "noreply@staffplan.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.invites.invite.subject
  #
  def existing_user_invite(email, sender)
    @sender = sender

    mail to: email,
      subject: "Invitation from #{sender.full_name} to join a company on StaffPlan"
  end

  def new_user_invite(email, sender)
    @sender = sender

    mail to: email,
      subject: "Invitation from #{sender.full_name} to join a company on StaffPlan"
  end

  def response_email(user, invite)
    @user = user
    @invite = invite

    mail to: invite.sender.email,
      subject: "Invite was responded to"
  end
end
