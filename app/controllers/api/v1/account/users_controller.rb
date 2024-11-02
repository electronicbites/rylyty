class Api::V1::Account::UsersController < Api::BaseController
  respond_to :json
  before_filter :authenticate_user!

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
  		render json: {success: true}
  	else
  		render json: {success: false, message: @user.errors.full_messages.join(',')}
  	end
  end

  def add_facebook_id
    current_user.facebook_id = params['facebook_id']
    current_user.save!
    render json: { success: true, message: I18n.t('users.facebook_id_saved'), facebook_id: current_user.facebook_id }, status: 200
  end

  def facebook_friends
    facebook_friends = params['facebook_friends']
    friends = User.find_friends_by_facebook_ids facebook_friends, current_user
    if !friends.empty?
      render json: {success: true, message: I18n.t('users.fb_friends_found'), friends: friends }, status: 200
    else
      render json: {success: false, message:  I18n.t('users.no_fb_friends_found')}, status: 200
    end 
  end

  def find_friends
    emails = params['emails'].split(' ');
    @users = User.find_friends_by_emails emails, current_user, create_friendship=false
    if !@users.empty?
      render '/api/v1/users/index'
    else
      render json: {success: false, message:  I18n.t('users.no_fb_friends_found') }, status: 200
    end
  end

  def add_friends
    emails = params['emails'].split(' ');
    friends = User.find_friends_by_emails emails, current_user
    if !friends.nil?
      render json: {success: true, message:  I18n.t('users.friends_found')}
    else
      render json: {success: false, message:  I18n.t('users.no_friends_found')}
    end
  end
end