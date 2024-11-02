# called via instrumentation/notification after an invitaition was accepted.
class InvitationAcceptedWorker

  def self.perform event_name, *args
    features = args.last
    case event_name
    when 'set_invitation_accepted_badges'
      invitation = features[:for]
      badges = BadgeFinder::beta_invites invitation

      # early_bird_active = true # todo: either remove somewhen or User.count <= 1000 or so
      # InvitationAcceptedWorker.early_bird_invitee(invitation) if early_bird_active
      
      # if InvitationBadgeModel.invitation_badge_models.present?
      #   # get badge_context for invitation.invited_by.invitations.size
      #   badge_context = InvitationBadgeModel.invitation_badge_models.first.num_accepted_invitations_badge_context_map[invitation.invited_by.invitations.size]
      #   if badge_context.present?
      #     invitation.invited_by.earn_user_badge badge_context.badge, badge_context
      #     Rails.logger.debug "rewarded user #{invitation.invited_by.username} with badge #{badge_context.badge.title}"
      #   end
      # else
      #   Rails.logger.warn "no invitation-badge-contexts defined"
      # end
    end
  end
  
  def self.early_bird_invitee invitation
    # badge_context_name = 'user.erster'
    # badge_context = BadgeContext.context_for_name badge_context_name
    # if badge_context.present?
    #   invitation.invitee.earn_user_badge badge_context.badge, badge_context
    #   invitation.invitee.save
    # else
    #   Rails.logger.warn "no badge with context-name #{badge_context_name} for user #{invitation.invitee.username}"
    # end
  end
  
end
