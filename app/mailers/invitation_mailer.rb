class InvitationMailer < MandrillMailer

  ##
  # @TODO: this action may need to switch it's mandrill
  #        template according to the state/informations
  #        given by the invitation!
  #        (e.g: `#initial_beta_invite?`)
  def invited to, invitation_id, add_vars=nil
    invitation = Invitation.find(invitation_id)
    game_title = invitation.invited_to || ""
    invited_by_username = invitation.invited_by.try(:username) || "einem Freund"
    beta_invitations_budget = invitation.try(:beta_invitations_budget) || 0
    add_vars = (add_vars || {}).merge({
      game_title: game_title,
      invited_by_username: invited_by_username,
      invitation_url_iphone: new_user_registration_url(token: invitation.token),
      invitation_url_no_iphone: new_user_registration_url(token: invitation.token),
      beta_invitations_budget: beta_invitations_budget
    })

    mail to: to,
         subject: "Einladung zum rylyty-Spiel"

    chimp_headers('beta_invitation', add_vars)
  end

  ##
  # Send's the reminder mail where/how to install the beta-app
  def beta_download_reminder invitation_id, add_vars=nil
    invitation = Invitation.find(invitation_id)
    invitee = invitation.invitee
    add_vars = (add_vars || {}).merge({
      invitee_username: invitee.username,
      invitation_url_iphone: new_user_registration_url(token: invitation.token),
      invitation_url_no_iphone: new_user_registration_url(token: invitation.token),
      invitation_download_link: invitation.download_link.generate_url(direct: 1)

    })

    mail to: invitee.email,
         subject: "Erinnerung zum rylyty-Spiel"

    chimp_headers('beta_download', add_vars)
  end

end
