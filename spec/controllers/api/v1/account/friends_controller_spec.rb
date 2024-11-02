require 'spec_helper'

describe Api::V1::Account::FriendsController do
  render_views

  context "list friends" do
    let(:user) {FactoryGirl.create(:user)}
    let(:friends) {FactoryGirl.create_list(:user, 3)}

    context('three friends') do
      before(:each) do
        friends.each{|f| user.become_friends_with f}
        user.friends.size.should == friends.size
        sign_in :user, user
      end

      it 'should be successfull' do
        get :index, format: :json
        response.status.should == 200
      end

      it 'should return a collection containing all 3 friends' do
        get :index, format: :json
        json = parse_json
        json['friends'].size.should == user.friends.size
        json['friends'].collect{|user| user['username']}.should =~ friends.collect(&:username)
      end
    end

    context('only one friend') do
      let(:the_one_and_only_friend) {friends.first}

      before(:each) do
        user.become_friends_with the_one_and_only_friend
        user.friends.size.should == 1
        sign_in :user, user
      end

      it 'should be successfull' do
        get :index, format: :json
        response.status.should == 200
      end

      it 'should return a collection containing the one and only friend' do
        get :index, format: :json
        json = parse_json
        json['friends'].size.should == user.friends.size
        json['friends'].first['username'].should == the_one_and_only_friend.username
      end

      it 'should not return a users name who is not a friend' do
        get :index, format: :json
        json = parse_json
        json['friends'].size.should == user.friends.size
        json['friends'].collect{|user| user['username']}.should_not include friends.last.username
      end

      it 'should set attribute my_friend true for all' do
        get :index, format: :json
        parse_json['friends'].each{|user_hash| user_hash['my_friend'].should be_true}
      end
    end

    context('no friends') do
      before(:each) do
        sign_in :user, user
      end

      it 'should be successfull' do
        get :index, format: :json
        response.status.should == 200
      end

      it 'should return a emnpty collection' do
        get :index, format: :json
        parse_json['friends'].should be_empty
      end
    end


    it 'should return 401 for !logged_in user' do
      get :index, format: :json
      response.status.should == 401
      response.body.should_not include('friends')
    end
  end
end
