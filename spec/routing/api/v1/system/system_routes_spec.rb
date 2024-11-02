require 'spec_helper'

describe 'routing to system controllers' do

  it '/api/v1/system/info.json' do
    {get: '/api/v1/system/info.json'}.should route_to(
      controller: 'api/v1/system',
      action: 'info',
      format: 'json'
    )
  end
end