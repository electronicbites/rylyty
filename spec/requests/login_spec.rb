require 'spec_helper'

describe '#login' do
  context 'rylyty user' do
    let(:user) {FactoryGirl.create(:user, username: 'humpty', password: 'secret', password_confirmation: 'secret')}

    it 'should be successful with correct credentials using username' do
      post '/api/v1/login', login: user.username, password: user.password
      response.should be_success
    end

    it 'should be successful with correct credentials using email' do
      post '/api/v1/login', login: user.email, password: user.password
      response.should be_success
    end

    it 'successful login with username should return success: true' do
      post '/api/v1/login', login: user.username, password: user.password
      parse_json['success'].should be_true
    end

    it 'successful login with email should return success: true' do
      post '/api/v1/login', login: user.email, password: user.password
      parse_json['success'].should be_true
    end

    it 'bad login should return success: false' do
      post '/api/v1/login', login: 'bad_foo', password: user.password
      parse_json['success'].should be_false
    end
    
    it 'missing logon parameterreturn success: false' do
      post '/api/v1/login', password: user.password
      parse_json['success'].should be_false
    end
  end

  context 'facebook user' do
    
    it 'successful login with accesstoken should return success: true', vcr:true do
      fb_app_id = '123456789356813'
      fb_secrete =  'huh2e6m12345678999e123f3dxw123s1'
      
      if VCR.current_cassette.recording?
        fb_app_id = ENV['FB_APP_ID']
        fb_secrete = ENV['FB_SECRET']
      end

      test_users = Koala::Facebook::TestUsers.new(:app_id => fb_app_id, :secret => fb_secrete)

      test_user = test_users.create(true, "offline_access,read_stream")
      user = FactoryGirl.create(:user, facebook_id: test_user['id'], username: 'humpty')
      post '/api/v1/login_with_facebook', facebook_access_token: test_user['access_token'], facebook_id: user.facebook_id
      parse_json['success'].should be_true
      test_users.delete(test_user)
    end

    it 'returns an error if login fails' do
      post '/api/v1/login_with_facebook', facebook_access_token: 'some_wrong_testtoken_for_fb', facebook_id: '123456789'
      parse_json['success'].should be_false
    end
  end
end


describe '#logout' do
  let(:user) {FactoryGirl.create(:user, username: 'humpty', password: 'secret', password_confirmation: 'secret')}

  before(:each) do
    User.destroy_all
  end

  it 'should be successful when user is loggedin' do
    post '/api/v1/login', username: user.username, password: user.password
    get '/api/v1/logout'
    response.should be_success
  end
end