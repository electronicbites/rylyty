require 'spec_helper'

I18n.locale = 'de'

describe BetaUsersController do
  
  describe 'register new beta_user' do
    render_views

    it 'should create new beta_user' do
      expect {
        post :create, beta_user: FactoryGirl.attributes_for(:beta_user), format: :js
      }.to change(BetaUser, :count).by(1)
    end

    it 'should save a beta user with the correct email' do
      attributes = FactoryGirl.attributes_for(:beta_user)
      post :create, beta_user: attributes, format: :js
      assigns(:beta_user).email.should == attributes[:email]
    end

    it 'should not be confirmed' do
      attributes = FactoryGirl.attributes_for(:beta_user)
      post :create, beta_user: attributes, format: :js
      assigns(:beta_user).should_not be_confirmed
    end

    it 'should not create new beta_user with existing email' do
      existing_beta_user = FactoryGirl.create(:beta_user)
      expect {
        post :create, beta_user: {email: existing_beta_user.email}, format: :js
      }.to_not change(BetaUser, :count)
    end

    it 'should send the activation mail' do
      post :create, beta_user: FactoryGirl.attributes_for(:beta_user), format: :js
      ActionMailer::Base.deliveries.find{|email| email.to == [assigns(:beta_user).email] }.should be_present
    end
  end

  describe 'confirm beta_user' do
    render_views
    let(:beta_user) {FactoryGirl.create(:beta_user_not_confirmed)}

    it 'should show the success page' do
      get :confirm, confirmation_token: beta_user.confirmation_token
      response.body.should include 'erfolgreich'
      response.body.should include 'Anmeldung'
    end

    it 'should confirm a user' do
      get :confirm, confirmation_token: beta_user.confirmation_token
      beta_user.reload.should be_confirmed
    end
  end
end
