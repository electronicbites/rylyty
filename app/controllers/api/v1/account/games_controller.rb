class Api::V1::Account::GamesController < Api::BaseController
  respond_to :json
  before_filter :authenticate_user!

  def index
    @user_games = current_user.user_games
    render 'index'
  end

  def show
    @user_game = current_user.user_games.find_by_game_id params[:id]
    render 'show'
  end

  def update_privacy
    user = current_user
    user_game = UserGame.where(game_id: params[:game_id], user_id: user.id).first
    user_game.feed_visibility = params[:feed_visibility]

    if user_game.save
      return render json: { success: true, message:I18n.t('user_games.visibility_settings_sucessfully_updated') }, status: 200
    else
      return render json: { success: false, message: I18n.t("user_games.#{user_game.errors.messages[:feed_visibility].first}") }, status: 200
    end
  end

end