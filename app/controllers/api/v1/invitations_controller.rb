class Api::V1::InvitationsController < Api::BaseController
  respond_to :json
  before_filter :authenticate_user!

  def create
    if (email = params.delete(:email))
      platform_invite email, params[:game]
    elsif (friend = params.delete(:friend)) && (game = params.delete(:game))
      game_invite friend, game
    end
  end

  private

  def platform_invite email, game=nil
    invited_to = nil
    return record_not_found "missing invitee" if !email
    return record_not_found "game not found" unless (game && invited_to = Game.find(game))
    return record_not_found "you cannot invite this user" unless current_user.beta_invite(email, invited_to)
    render json: {success: true, beta_invitations_left: (current_user.beta_invitations_budget - current_user.beta_invitations_issued)}
    
    rescue ActiveRecord::RecordNotUnique
      record_not_found "you invited this user already"
  end

  def game_invite friend, game
    
    invitee = User.find(friend)
    invited_to = Game.find(game)

    return record_not_found "missing invitee" if !invitee
    return record_not_found "missing game" if !invited_to

    if !current_user.invite(invitee, invited_to)
      return record_not_found "you cannot invite this user"
    end

    render json: {success: true, game_invitation_send_for: invited_to.title}

  end

end