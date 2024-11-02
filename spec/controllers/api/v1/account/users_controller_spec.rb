require 'spec_helper'

describe Api::V1::Account::UsersController do

  context "update" do
    let(:user) {FactoryGirl.create(:user)}

    before(:each) do
      sign_in :user, user
    end

    context 'update avatar' do

      it 'should attach the avatar' do
        post :update, user: {avatar: fixture_file_upload(Rails.root + 'spec/rails.png', 'image/png')}
        user.reload.avatar_file_name.should be_present
      end

      it 'should return success' do
        post :update, user: {avatar: fixture_file_upload(Rails.root + 'spec/rails.png', 'image/png')}
        response.body.should match /\"success\":true/
      end
    end

    context 'find friends' do
      let(:user) {FactoryGirl.create(:user)}
      let(:second_user) {FactoryGirl.create(:user)}
      let(:third_user) {FactoryGirl.create(:user)}

      it 'adds a new friend' do
        emails = second_user.email + ' ' + third_user.email

        expect {
          post :add_friends, {emails: emails}
        }.to change {Friendship.count}.by(2)
      end
      it 'does not add a friend, no friend was found' do
        emails = 'huhu@example.com'
        expect {
          post :add_friends, {emails: emails}
        }.to change {Friendship.count}.by(0)
    
      end
      
      it 'find new friends and return found users' do
        emails = second_user.email + ' ' + third_user.email + ' test@example.com'
        expect {
           post :find_friends, {emails: emails, format: :json}
        }.to change {Friendship.count}.by(0)
        assigns(:users).should_not be_nil
        assigns(:users).count.should == 2
      end

      it 'find new friends and return found users' do
        emails = 'test@example.com' 
        expect {
           post :find_friends, {emails: emails, format: :json}
        }.to change {Friendship.count}.by(0)
        assigns(:users).should be_empty
      end
    end
    
  end
end