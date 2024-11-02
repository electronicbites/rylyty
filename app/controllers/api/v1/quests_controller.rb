class Api::V1::QuestsController < Api::BaseController
  respond_to :json
  before_filter :authenticate_user!

  def index
    @quests = Quest.all
    render 'index'
  end

  def show
    @quest = Quest.find(params[:id])
    render 'show'
  end

end