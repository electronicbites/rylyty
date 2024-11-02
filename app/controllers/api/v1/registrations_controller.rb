class Api::V1::RegistrationsController < Api::BaseController
  respond_to :json
  
  def create
    user = User.new(params[:user])
    if !user.save
      # check if fb-registration should be merged with existing rylyty-user
      merge_user = register_rylyty_user_with_fb_credentials user
      if  merge_user.present?
        # @see Api::V1::SessionsController - create.
        is_first_login = (merge_user.sign_in_count > 0)
        sign_in(:user, merge_user)
        render json: { success: true, username: merge_user.username, email: merge_user.email, id: merge_user.id, first_login: is_first_login }, status: 201
        return
      end
      logger.error user.errors.full_messages.join ','
      warden.custom_failure!
      facebook_id = User.find_by_email(user.email).try(:facebook_id)
      render json: (facebook_id.blank? ? user.errors : { prompt: "\"fb_id\": #{facebook_id}" }), status: 422
    end
    if user.persisted?
      user.upload_facebook_avatar_async if fbdata
      user.default_credits
      sign_in("user", user)
      BadgeFinder::early_bird user
      render_user_created_with_success user
    end
  end

  protected

  def render_user_created_with_success user
    render json: user.as_json(email: user.email), status: 201
  end

  def fbdata
    params[:user][:facebook_id]
  end

  def register_rylyty_user_with_fb_credentials invalid_user
    return nil unless fbdata
    return User.merge_rylyty_user_with_fb_user(invalid_user) if invalid_user.errors[:email].present? || invalid_user.errors[:facebook_id].present?
    nil
  end

end