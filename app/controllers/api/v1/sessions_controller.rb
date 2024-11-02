class Api::V1::SessionsController < Api::BaseController
  before_filter :ensure_params_exist, only: :create
  respond_to :json

  def create
    resource = User.find_for_database_authentication(login: params[:login])
    return invalid_login_attempt unless resource

    if resource.valid_password?(params[:password])
      sign_in("user", resource)
      render json: { success: true, username: resource.username, email: resource.email, id: resource.id, server_timestamp: Time.now.to_i }
      return
    end
    invalid_login_attempt
  end


  def create_with_facebook
    begin graph = Koala::Facebook::API.new(params[:facebook_access_token])     
      fb_id = graph.get_object("me") { |data| data['id'] }
      resource =  User.where(facebook_id: fb_id).first
      return invalid_login_attempt unless resource
    rescue
      return invalid_login_attempt
    end
    sign_in("user", resource)
    render json: { success: true, username: resource.username, email: resource.email, id: resource.id }
  end


  def destroy
    sign_out
    render json: { success: true }
  end

  protected

  def ensure_params_exist
    return unless params[:login].blank?
    render json: { success: false, message: I18n.t("login.errors.missing_login_parameter") }, status: 422
  end

  def invalid_login_attempt
    warden.custom_failure!
    render json: { success: false, message: I18n.t("login.errors.error_with_login_or_password") }, status: 401
  end
end