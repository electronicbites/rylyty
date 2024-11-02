require 'spec_helper'

describe 'routing to tasks' do

  it '/api/v1/tasks/123/' do
    {get: '/api/v1/games/123/tasks'}.should route_to(
      controller: 'api/v1/tasks',
      action: 'index',
      game_id: '123'
    )
  end


  it '/api/v1/tasks/123' do
    {get: '/api/v1/tasks/123'}.should route_to(
      controller: 'api/v1/tasks',
      action: 'show',
      id: '123'
    )
  end
end