class Api::V1::FriendsController < Api::BaseController
  respond_to :json
  before_filter :authenticate_user!

  def index
    user = User.find(params['user_id'])
    @users = user.friends
    render 'api/v1/friends/index'
  end

end