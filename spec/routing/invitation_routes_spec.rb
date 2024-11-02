require 'spec_helper'

describe 'routing to devise invitations' do

  it '/users/invitation/accept?token=123abc' do
    {get: '/users/invitation/accept', token: '123abc'}.should route_to(
      controller: 'invitation',
      action: 'new'
    )
  end

end