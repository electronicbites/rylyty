#encoding: UTF-8
require 'spec_helper'

describe Api::V1::UsersController do

  context "json" do
    render_views
    
    let(:user) { FactoryGirl.create(:user) }
    let(:badge) {FactoryGirl.create(:badge)}
    
    describe 'show' do
      before(:each) do
        sign_in :user, user
        user.earn_user_badge badge
      end
  
      it 'should show badges' do
        get :show, {
          format: :json,
          id: user.id.to_s
        }
        json = parse_json['user']
        
        json.should have_key 'badges'
        json['badges'].size.should == 1
        json['badges'].first.should have_key 'id'
        json['badges'].first['id'].should == user.badges.first.id
      end
    end
  end
  
  describe '#request_password_reset' do
    let(:user) {FactoryGirl.create(:user)} 

    it "requiring to reset a password should set the token" do
      expect {
        post :request_password_reset, :email => user.email
      }.to change {user.reload.reset_password_token}
    end
    
    it "resetting the password should send an email with the token" do
      post :request_password_reset, :email => user.email
      ActionMailer::Base.deliveries.find{|email| email.to == [user.email] }.should be_present
    end
    
    it "resetting password with wrong email should not send mail to user" do
      expect {
        post :request_password_reset, :email => "foo@notexisiting.com"
      }.not_to change{ActionMailer::Base.deliveries.size}
    end
    
    it "require to reset a password with a wrong email should show an error message" do
      post :request_password_reset, :email => "foo@notexisiting.com"
      response.body.should match /\"success\":false/
      parse_json['message'].should match "Ohne deine E-Mail- Adresse geht hier leider gar nichts."
    end
  end

  describe 'check username' do
    let(:user) {FactoryGirl.create(:user, username: 'foobar')}
    
    it 'returns an error if the usernam is already assigned' do
      user.username = 'foobar'
      user.save 
      get :check_username, username: 'foobar'
      expect {
        parse_json['success'].to be_false
      }
      parse_json['message'].should match "Dieser Benutzername ist schon vergeben."
    end

    it 'returns an error if the username is not valid' do
      get :check_username, username: 'foo bar'
      expect {
        parse_json['success'].to be_false
      }
      parse_json['message'].should match "Mmh, das ist zu kreativ. Lass mal die Sonderzeichen weg."
    end

    it 'returns an error if the username is blank' do
      get :check_username, username: ' '
      expect {
        parse_json['success'].to be_false
      }
      parse_json['message'].should match "Dein Benutzername fehlt noch."
    end

    it 'returns succes if no errors occur' do
      get :check_username, username: 'foobar_23'
      expect {
        parse_json['success'].to be_true
      }
    end
  end
end