require 'spec_helper'

describe 'routing to games' do

  it '/api/v1/my/games.json' do
    {get: '/api/v1/my/games.json'}.should route_to(
      controller: 'api/v1/account/games',
      action: 'index',
      format: 'json'
    )
  end

  it '/api/v1/my/games/:game_id.json' do
    {get: '/api/v1/my/games/123.json'}.should route_to(
      controller: 'api/v1/account/games',
      action: 'show',
      id: '123',
      format: 'json'
    )
  end

  it '/api/v1/my/games/:game_id/privacy.json' do
    {put: '/api/v1/my/games/123/privacy.json'}.should route_to(
      controller: 'api/v1/account/games',
      action: 'update_privacy',
      game_id: '123',
      format: 'json'
    ) 
  end
end
