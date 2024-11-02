require 'spec_helper'

describe 'routing to users' do

  it '/api/v1/signup' do
    {post: '/api/v1/signup'}.should route_to(
      controller: 'api/v1/registrations',
      action: 'create'
    )
  end

  it '/api/v1/login' do
    {post: '/api/v1/login'}.should route_to(
      controller: 'api/v1/sessions',
      action: 'create'
    )
  end

  it '/api/v1/login_with_facebook' do
    {post: '/api/v1/login_with_facebook'}.should route_to(
      controller: 'api/v1/sessions',
      action: 'create_with_facebook'
    )
  end
end
