require 'spec_helper'

describe 'routing to quests' do

  it '/api/v1/quests.json' do
    { get: '/api/v1/quests.json' }.should route_to(
      controller: 'api/v1/quests',
      action: 'index',
      format: 'json'
    )
  end

  it '/api/v1/quests/:quest_id.json' do
    { get: '/api/v1/quests/123.json'}.should route_to(
      controller: 'api/v1/quests',
      action: 'show',
      id: '123',
      format: 'json'
    )
  end
end