class Api::V1::Account::FeedItemsController < Api::BaseController
  respond_to :json
  before_filter :authenticate_user!#, :set_locale

  def games
    limit = params['limit'] || 20
    @feed_items = FeedItem.game_feed_items  params['startkey'] || 0, limit
    render 'games'
  end


  def news
    limit = params['limit'] || 20
    @feed_items = FeedItem.news_feed_items current_user.id, params['startkey'] || 0, limit
    render 'news'
  end

  def friends
    limit = params['limit'] || 20
    @feed_items = FeedItem.friend_feed_items current_user.id, params['startkey'] || 0, limit
    render 'friends'
  end

end