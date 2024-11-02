require 'spec_helper'

describe 'routing to users' do

  it '/api/v1/my/profile.json' do
    {put: '/api/v1/my/profile.json'}.should route_to(
      controller: 'api/v1/account/users',
      action: 'update',
      format: 'json'
    )
  end

  it '/api/v1/my/profile/add_facebook_id.json' do
    {post: '/api/v1/my/profile/add_facebook_id.json'}.should route_to(
      controller: 'api/v1/account/users',
      action: 'add_facebook_id',
      format: 'json'
    )
  end

  it '/api/v1/my/profile/facebook_friends.json' do
    {post: '/api/v1/my/profile/facebook_friends.json'}.should route_to(
      controller: 'api/v1/account/users',
      action: 'facebook_friends',
      format: 'json'
    )
  end

  it '/api/v1/my/profile/add_friends.json' do
    {post: '/api/v1/my/profile/add_friends.json'}.should route_to(
      controller: 'api/v1/account/users',
      action: 'add_friends',
      format: 'json'
    )
  end

  it '/api/v1/my/profile/find_friends.json' do
    {post: '/api/v1/my/profile/find_friends.json'}.should route_to(
      controller: 'api/v1/account/users',
      action: 'find_friends',
      format: 'json'
    )
  end
end
