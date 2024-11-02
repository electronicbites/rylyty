require 'spec_helper'

describe 'routing to home' do
  it '/' do
    {get: '/'}.should route_to(
      controller: 'home',
      action: 'index'
    )
  end

  it '/impressum' do
    {get: '/impressum'}.should route_to(
      controller: 'home',
      action: 'impressum'
    )
  end
end
