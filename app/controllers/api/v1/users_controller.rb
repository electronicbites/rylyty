class Api::V1::UsersController < Api::BaseController
  respond_to :json
  before_filter :authenticate_user!, except: [:request_password_reset, :check_username]

  def show
    begin @user = User.find(params[:id])
      render 'show'
    rescue ActiveRecord::RecordNotFound
      render json:{json:false, message:I18n.t('users.errors.user_not_found')}, status:404
    end
  end

  def request_password_reset
    user = User.find_by_email(params[:email])
    if user.present?
      user.send_reset_password_instructions
      response_json = {success: true}
    else
      response_json = {success: false, error: 'invalid_email', message: I18n.t('users.errors.password_reset.invalid_email')}
    end
    render json: response_json
  end

  def check_username
    mock = User.new(username: params[:username])
    mock.valid?(:create)
    errors = mock.errors

    if !errors[:username].empty?
      render json:{json:false, message:  mock.errors[:username].first}, status: 200
    else
      render json:{json:true, message:  I18n.t('users.user_name_available')}, status: 200
    end
  end
  
end