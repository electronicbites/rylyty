require 'spec_helper'

describe '/signup' do

  it 'should create a user per json api' do
    attrs = {email: 'foo@example.com', password: '123456', password_confirmation: '123456',
          username: 'asdasd', birthday: '13.10.1973', tos: 'true'}
    expect {
      post '/api/v1/signup.json', {
        user: attrs
      }
    }.to change(User, :count).by(1)
    response.status.should == 201
    json = parse_json

    json['email'].should      be_present
    json['email'].should      == attrs[:email]
    json['id'].should         be_present
    user =  User.find(json['id'])
    user.should be_instance_of(User)
    user.credits.should == 10
  end

  it 'should create a facebook user' do
    expect {
      post '/api/v1/signup.json', {user: {
            email: 'foo@example.com',
            username: 'asdasd',
            facebook_profile_url: 'https://graph.facebook.com/123123123/picture?type=large',
            facebook_id: '123123123',
            tos: 'true'}}
    }.to change(User, :count).by(1)
    response.status.should == 201
    json = parse_json

    json['facebook_id'].should      be_present
    json['facebook_id'].should      == '123123123'
    json['id'].should               be_present

    user =  User.find(json['id'])
    user.should be_instance_of(User)
    user.credits.should == 10
    user.avatar.should_not == '/avatars/original/missing.png'
    user.avatar.should_not be_nil
  end


  it 'should return an error message when user already exist' do
    FactoryGirl.create(:user, username: 'gabi.palomino')
    expect {
      post '/api/v1/signup.json', {user: {
        username: "gabi.palomino",
        facebook_profile_url: "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash4/369545_813899508_1088025188_n.jpg",
        email: "gabi.palomino@gmail.com",
        facebook_id: "813899508"}}
    }.not_to change(User, :count)
    response.status.should == 422
  end


  it 'with missing email no user should be created' do
    attrs = {password: '123456', password_confirmation: '123456', username: 'asdasd'}
    expect {
      post '/api/v1/signup.json', {
        user: attrs
      }
    }.not_to change(User, :count)
  end

  it 'should return errormessage in case of wrong email' do
    pending 'analyse error message'
  end
end

describe '/api/v1/users/:user_id.json' do
  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }

  it 'should return 302 if user is not logged in' do
    get "/api/v1/users/#{other_user.id}.json"
    response.status.should == 401
  end

  it 'should answer with status 200' do
    sign_in_as user
    get "/api/v1/users/#{other_user.id}.json"
    response.status.should == 200
  end

  it 'should respond_with_content_type :json' do
    sign_in_as user
    get "/api/v1/users/#{other_user.id}.json"
    response.content_type.should == "application/json"
  end

  it 'if the user does not exist return a 404' do
    sign_in_as user
    get "/api/v1/users/1234567.json"
    response.status.should == 404
  end

  it 'should return a valid json format' do
    sign_in_as user
    get "/api/v1/users/#{other_user.id}.json"
    response.status.should == 200
    json = JSON.parse response.body

    json['user'].has_key?('id').should be_true
    json['user'].has_key?('username').should be_true
  end

end

feature 'password reset' do

  let (:user) {FactoryGirl.create(:user)}

  before(:each) do
    clear_emails
    I18n.locale = 'de'
  end

  scenario 'init password reset from api with valid email' do
    # post user's email to request reset
    post '/api/v1/account/request_password_reset', { email: user.email }
    response.status.should == 200
    json = JSON.parse response.body
    json['success'].should be_true
    
    # check correct mail subject and text
    open_email user.reload.email
    current_email = emails_sent_to(user.reload.email).first
    current_email.find("a")['href'].should match /#{user.reset_password_token}/
  end
  
  scenario 'init password reset from api with invalid email' do
    invalid_email = 'foo@notexisiting.com'
    # post user's email to request reset
    post '/api/v1/account/request_password_reset', { email: invalid_email }
    response.status.should == 200
    json = JSON.parse response.body
    json['success'].should be_false
    json['error'].should == 'invalid_email'
    json['message'].should match "Ohne deine E-Mail- Adresse geht hier leider gar nichts."
    
    # check absence of mail
    emails_sent_to(invalid_email).should_not be_present
  end
end
