require 'spec_helper'

describe Api::V1::SystemController do
  render_views

  it 'should return server-timestamp' do
    get :info, format: :json
    parse_json.should have_key('timestamp')
  end

  it 'should return a news with the correct param version 0.9.0' do
    get :info, format: :json, version: '0.9.0'
    parse_json.should have_key('news')
  end


  it 'should not return a news without the correct param' do
    get :info, format: :json
    parse_json.should_not have_key('news')
  end
end