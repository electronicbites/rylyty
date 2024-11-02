require 'spec_helper'

describe 'routing to games' do

  it '/api/v1/missions/:mission_id/games.json' do
    {get: '/api/v1/missions/1/games.json'}.should route_to(
      controller: 'api/v1/games',
      action: 'index',
      format: 'json',
      mission_id: '1'
    )
  end

  it '/api/v1/games.json' do
    {get: '/api/v1/games.json'}.should route_to(
      controller: 'api/v1/games',
      action: 'index',
      format: 'json'
    )
  end

  it '/api/v1/games/:game_id.json' do
    {get: '/api/v1/games/123.json'}.should route_to(
      controller: 'api/v1/games',
      action: 'show',
      id: '123',
      format: 'json'
    )
  end

  it '/api/v1/games/:game_id/buy.json' do
    {post: '/api/v1/games/123/buy.json'}.should route_to(
      controller: 'api/v1/games',
      action: 'buy',
      game_id: '123',
      format: 'json'
    )
  end

  it '/api/v1/quests/:quest_id/games.json' do
    {get: '/api/v1/quests/123/games.json'}.should route_to(
      controller: 'api/v1/games',
      action: 'index',
      format: 'json',
      quest_id: '123'
    )
  end
end