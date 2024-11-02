require 'spec_helper'

describe Api::V1::RegistrationsController do
  render_views

  context 'failing registration' do
    it 'should return error' do
      post :create, {
        user: {email: 'foo@example.com', password: '123456', password_confirmation: '123456',
               username: 'asdasd', birthday: '13.10.1973'}
      }, format: :json                        
      response.response_code.should == 422
      json = ActiveSupport::JSON.decode(response.body)
      warden.authenticated?(:user).should be_false
    end
  end

  context 'successful registration' do
    it 'should return server-timestamp' do
      post :create, {
        user: {email: 'foo@example.com', password: '123456', password_confirmation: '123456',
               username: 'asdasd', birthday: '13.10.1973', tos: 'true'}
      }, format: :json                        
      response.response_code.should == 201
      json = ActiveSupport::JSON.decode(response.body)
      warden.authenticated?(:user).should be_true
    end

    it 'should merge account if rylyty-registered user registers with facebook' do
      rylyty_registered_user = FactoryGirl.create(:user)
      fb_id = rand(999999999).to_s.ljust(9, '0')
      post :create, {
        user: {email: rylyty_registered_user.email,
               username: rylyty_registered_user.username,
               facebook_profile_url: "https://graph.facebook.com/#{fb_id}/picture?type=large",
               facebook_id: fb_id,
               tos: 'true'}
      }, format: :json               
      response.response_code.should == 201
      json = ActiveSupport::JSON.decode(response.body)
      warden.authenticated?(:user).should be_true
    end

    it 'should display login-hint if fb-registered user registers with rylyty' do
      fb_registered_user = FactoryGirl.create(:facebook_user)
      post :create, {
        user: {email: fb_registered_user.email, password: '123456', password_confirmation: '123456',
               username: fb_registered_user.username, birthday: '13.10.1973', tos: 'true'}
      }, format: :json               
      response.response_code.should == 422
      json = ActiveSupport::JSON.decode(response.body)
      json['prompt'].should be_present
      warden.authenticated?(:user).should be_false
    end

    it 'should get Early-Bird-Badge' do
      # initialize badgeable event 
      badge = FactoryGirl.create(:badge, title: 'Early-Bird-Badge') 
      badge.context = "badge_type => early_bird"
      badge.save   
      username = 'asdasd'
      expect {
        post :create, {
          user: {email: 'foo@example.com', password: '123456', password_confirmation: '123456',
                 username: username, birthday: '13.10.1973', tos: 'true'}
        }, format: :json                        
      }.to change(User, :count).by(1)
      user = User.find_by_username(username)
      User.find_by_username(username).badges.should include badge
   end
  end

  context 'facebook reassigns' do
    it 'should allow re-assigns with facebook' do
      fb_registered_user = FactoryGirl.create(:facebook_user)
      post :create, {
        user: {email: fb_registered_user.email,
               username: fb_registered_user.username,
               facebook_profile_url: "https://graph.facebook.com/#{fb_registered_user.facebook_id}/picture?type=large",
               facebook_id: fb_registered_user.facebook_id,
               tos: 'true'}
      }, format: :json               
      response.response_code.should == 201
      json = ActiveSupport::JSON.decode(response.body)
      warden.authenticated?(:user).should be_true
    end
    
    # 1) register user with rylyty
    # 2) connect with facebook
    # 3) signup with same facebook id
    # ==>  facebook_id already taken
    it 'should allow re-assigns with facebook' do
    # @extends it 'should merge account if rylyty-registered user registers with facebook' do
      rylyty_registered_user = FactoryGirl.create(:user)
      
      fb_id = rand(999999999).to_s.ljust(9, '0')
      post :create, {
        user: {email: rylyty_registered_user.email,
               username: rylyty_registered_user.username,
               facebook_profile_url: "https://graph.facebook.com/#{fb_id}/picture?type=large",
               facebook_id: fb_id,
               tos: 'true'}
      }, format: :json               
      response.response_code.should == 201
      json = ActiveSupport::JSON.decode(response.body)
      warden.authenticated?(:user).should be_true
      
      sign_out :user

      post :create, {
        user: {email: rylyty_registered_user.email,
               username: rylyty_registered_user.username,
               facebook_profile_url: "https://graph.facebook.com/#{fb_id}/picture?type=large",
               facebook_id: fb_id,
               tos: 'true'}
      }, format: :json               
      response.response_code.should == 201
      json = ActiveSupport::JSON.decode(response.body)
      warden.authenticated?(:user).should be_true
    end
  end
end