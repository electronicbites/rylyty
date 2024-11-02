class Api::V1::Account::BadgesController < Api::BaseController
  respond_to :json
  before_filter :authenticate_user!

  def index
    @user = current_user
    @badges = @user.badges
    render 'api/v1/badges/index'
  end
end