require 'spec_helper'

describe 'routing to my/feeds' do
  it '/api/v1/my/feeds/games' do
    { get: '/api/v1/my/feeds/games'}.should route_to(
      controller: 'api/v1/account/feed_items',
      action: 'games'
    )
  end
end