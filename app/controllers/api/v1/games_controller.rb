class Api::V1::GamesController < Api::BaseController
  respond_to :json
  before_filter :authenticate_user!

  def index
    # these games ar sorted!
    @recommended_games = Game.recommended_games||[]

    return search  if params[:q].present?
    return suggest if params[:suggest].present?
    return mission if params[:mission_id].present?
    return quest   if params[:quest_id].present?

  	# all games without a mission id
  	# rable views
    # add recommended games on top of list on first page only
    @games = (params[:offset].to_i <= 1 ? @recommended_games : [])|Game.without_mission.limit( params[:limit] ).offset( params[:offset] )
    render 'index'
  end

  def show
    @game = Game.find(params[:id])
    render 'show'
  ##
  # @todo comment the next two lines back in, if this messages
  #       is really needed that way. Atm, I can't see why.
  # rescue ActiveRecord::RecordNotFound => e
  #   record_not_found "game could not be found"
  end

  def buy
    @user = current_user
    @game = Game.find(params[:game_id])

    if current_user.can_play @game
      begin
        @user_game = current_user.buy_game! @game
        render 'api/v1/account/games/show'
      rescue ActiveRecord::RecordInvalid => e
        msg = I18n.t('users.errors.buying_game.intro')
        msg << e.message
        render json: {success: false, message: msg}, status: 200
      end
    else
      msg = I18n.t('users.errors.buying_game.intro')
      msg << @user.errors[:base].join("\n")
      render json: {success: false, message: msg}, status: 200
    end
  end


  private

    def mission
      @user = current_user
      # add recommended games with given mission on top of list
      recommended_games = @recommended_games
                          .find_all{|g|g.missions.present? && g.missions.find{|m|m.id==params[:mission_id].to_i}}||[]
      @games = recommended_games|Mission.find(params[:mission_id]).games
      render 'index'
    ##
    # @todo comment the next two lines back in, if this messages
    #       is really needed that way. Atm, I can't see why.
    # rescue ActiveRecord::RecordNotFound => e
    #   record_not_found "mission could not be found"
    end

    def quest
      @user = current_user
      quest = Quest.find(params[:quest_id])
      # add recommended games with given quest on top of list
      recommended_games = @recommended_games
                          .find_all{|g|g.quest.present? && (g.quest.id==params[:quest_id].to_i)}||[]
      @games = recommended_games|quest.games

      render 'index'
    end

    def search
      query = params[:q]
      limit = params[:limit] || 10
      offset = params[:offset] || (limit * (params[:page] || 0))

      ##
      # @todo {#search} may notice us about stop words only queries
      #       we should try to include this into our response
      # add recommended games on top of list on first page only
      @games = (offset.to_i <= 1 ? @recommended_games : [])|Game.search_full_text(query.split(/\s+/)).limit(limit).offset(offset)
      @user = current_user
      render 'index'
    end

    def suggest
      limit = params[:limit] || 20

      @user = current_user
      # @todo reconcider the use of `.order("RANDOM()").limit(limit)` in favour of `all.sample(limit)`
      #       the first is very heavy on the DB, the other on ruby
      filtered_games = @user.purchasable_games
                       .where("suggestion is not null and suggestion != ''")
                       .order('RANDOM()').limit(limit)
      # add recommended games on top of list
      @games = @recommended_games|filtered_games
      render 'index_suggest'
    end
end
