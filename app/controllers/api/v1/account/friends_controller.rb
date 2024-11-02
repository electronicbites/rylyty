class Api::V1::Account::FriendsController < Api::BaseController
  respond_to :json
  before_filter :authenticate_user!

  def index
    @users = current_user.friends
    render 'api/v1/friends/index'
  end
end
