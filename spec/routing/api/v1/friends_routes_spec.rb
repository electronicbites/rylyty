require 'spec_helper'

describe 'routing to friends' do
  
  it '/api/v1/users/:id/friends.json' do
    { get: '/api/v1/users/123/friends.json'}.should route_to(
      controller: 'api/v1/friends',
      action: 'index',
      user_id: '123',
      format: 'json'
    )
  end

end
