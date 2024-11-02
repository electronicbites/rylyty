require 'spec_helper'

describe 'routing to my/friends' do
  it '/api/v1/my/friends' do
    { get: '/api/v1/my/friends'}.should route_to(
      controller: 'api/v1/account/friends',
      action: 'index'
    )
  end
end
