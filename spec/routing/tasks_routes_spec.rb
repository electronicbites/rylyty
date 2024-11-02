require 'spec_helper'

describe 'routing to tasks' do
  it 'index' do
    {get: '/api/v1/games/1/tasks'}.should route_to(
      controller: 'api/v1/tasks',
      action: 'index', 
      game_id: '1'
    )
  end
end