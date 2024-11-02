require 'spec_helper'

describe 'routing to categories' do

  it '/api/v1/categories.json' do
    { get: '/api/v1/categories.json' }.should route_to(
      controller: 'api/v1/categories',
      action: 'index',
      format: 'json'
    )
  end
end