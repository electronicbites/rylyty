# this class is a temporary storage for accepted_invitations-badge mappings
class InvitationBadgeModel

  # attr_accessor :num_accepted_invitations_badge_context_map
  
  # def initialize num_accepted_invitations_badge_context_map
  #   self.num_accepted_invitations_badge_context_map = num_accepted_invitations_badge_context_map
  #   # save all contexts if not exist @see BadgeContext - context_for_name
  #   num_accepted_invitations_badge_context_map.values.each{|badge_context|badge_context.save if badge_context.new_record?}
  # end
  
  # # maps a num of accepted invitations to badge_contexts
  # # the number of accepted invitations is the suffix of the badge_context-(context-)name
  # INVITATION_BADGE_MAPS = [
  #                           [ 'doorguard.1',
  #                             'doorguard.3',
  #                             'doorguard.10',
  #                             'doorguard.30',
  #                             'doorguard.50',
  #                             'doorguard.100' ]
  #                         ]
  
  # def self.invitation_badge_models
  #   models = []
  #   INVITATION_BADGE_MAPS.each do |bc_names|
  #     models << InvitationBadgeModel.new(Hash[*BadgeContext.context_for_name(bc_names, true).collect{|bc|[bc.name.match(/[0-9]+$/)[0].to_i, bc]}.flatten])
  #   end
  #   models
  # end
  
end