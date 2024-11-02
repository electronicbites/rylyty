require 'spec_helper'

describe Api::V1::FriendsController do

  context "json" do
    render_views
    
    let(:user) { FactoryGirl.create(:user) }
    
    describe 'index' do
      
      before(:each) do
        sign_in :user, user
      end
  
      it 'show list with 5 friends' do
        friends = Array.new 
        5.times {friends << FactoryGirl.create(:user)}
        friends.each {|friend| FactoryGirl.create(:friendship, friend: friend, user: user)}

        get :index, {
          format: :json,
          user_id: user.id.to_s
        }
        
        response.response_code.should == 200
        json = ActiveSupport::JSON.decode(response.body)
        json.should have_key 'friends'
        json['friends'].count.should == 5      
      end

      it 'throws no error if friend list is empty' do
        get :index, {
          format: :json,
          user_id: user.id.to_s
        }

        response.response_code.should == 200
        json = ActiveSupport::JSON.decode(response.body)
        json.should have_key 'friends'
        json['friends'].count.should == 0  
      end

    end
  end
end