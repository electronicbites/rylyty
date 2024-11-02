require 'spec_helper'

describe Api::V1::SessionsController do
  render_views

  context 'rylyty login' do
    it 'should return server-timestamp' do
      user = FactoryGirl.create(:user, password: 'secret')
      post :create, {login: user.username, password: 'secret'}, format: :json                        
      json = ActiveSupport::JSON.decode(response.body)
      json['server_timestamp'].should be_present
    end
  end

  context 'facebook login' do
    it 'should be successful', vcr: true do
      user = FactoryGirl.create(:facebook_user, facebook_id: '691806746')
      post :create_with_facebook, {facebook_id: user.facebook_id, facebook_access_token: 'foo'}, format: :json
      json = ActiveSupport::JSON.decode(response.body)
      response.should be_success
    end

    it 'should return status 401 when user not found', vcr: true do
      post :create_with_facebook, {facebook_id: '691806746', facebook_access_token: 'foo'}, format: :json
      json = ActiveSupport::JSON.decode(response.body)
      response.status.should == 401
    end
  end
end