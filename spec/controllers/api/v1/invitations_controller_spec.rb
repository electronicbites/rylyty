require 'spec_helper'

describe Api::V1::InvitationsController do

  context "json" do
    render_views
    
    let(:user) { FactoryGirl.create(:user) }
    let(:friend) { FactoryGirl.create(:user) }
    let(:game) {FactoryGirl.create(:game)}

    describe 'create' do
      
      before(:each) do
        FactoryGirl.create(:friendship, friend: friend, user: user)
        sign_in :user, user
      end

      it 'create a game invitation for a friend and a feed item' do
        post :create, {
          friend: friend.id,
          game: game.id,
          format: :json
        }

        json = JSON.parse response.body
        json['success'].should be_true
        json['game_invitation_send_for'].should == game.title

        feed_item = FeedItem.where(event_type: Invitation::EventTypes::GAME_INVITE_RECEIVED).first
        feed_item.should_not be_nil

      end

    it 'create a game invitation for a new user' do
        post :create, {
          game: game.id,
          email: "some_new_foo@example.com",
          format: :json
        }

        json = JSON.parse response.body
        json['success'].should be_true
        feed_item = FeedItem.where(event_type: Invitation::EventTypes::GAME_INVITE_RECEIVED).first
        feed_item.should be_nil

      end
    end
  end
end