class BetaUsersController < ApplicationController
  
  def create
    @beta_user = BetaUser.create_beta_user_with_token params[:beta_user]
    if @beta_user.save
      @beta_user.send_confirmation!
      render template: 'beta_users/thank_you'
    else
      logger.error @beta_user.errors.full_messages.join ','
      existing_user = BetaUser.where email: params[:beta_user][:email]
      @error_message = case
                        when existing_user.present?
                          'Diese E-Mail ist schon eingetragen!'
                        when @beta_user.email.blank?
                          'Die E-Mail muss angegeben werden!'
                        else
                          "Sorry, diese E-Mail ist nicht g#{"fc".hex.chr(Encoding::UTF_8)}ltig"
                        end
      render template: 'beta_users/error'
    end
  end

  def confirm
    @beta_user = BetaUser.find_by_confirmation_token params[:confirmation_token]
    @beta_user.confirm! if @beta_user.present?
  end
end
