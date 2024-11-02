require 'spec_helper'

describe 'routing to users' do

  it '/api/v1/users/:user_id.json' do
    {get: '/api/v1/users/123.json'}.should route_to(
      controller: 'api/v1/users',
      action: 'show',
      id: '123',
      format: 'json'
    )
  end

  it '/api/v1/users/check_username.json' do
    {get: '/api/v1/users/check_username.json'}.should route_to(
        controller: 'api/v1/users',
        action: 'check_username',
        format: 'json'
      )
  end
end
