require 'spec_helper'

describe '/api/v1/my' do

  describe "Cancel a User's Game Task" do
    it "generate a route" do
      assert_generates("/api/v1/my/tasks/1/cancel.json", {
        :controller => 'api/v1/account/tasks', :action => "cancel",
        :task_id => "1", :format => :json
      })
    end

    it "recognize route" do
      assert_recognizes({
        :controller => 'api/v1/account/tasks', :action => "cancel",
        :task_id => "1", :format => "json"
      }, {
        :path => "/api/v1/my/tasks/1/cancel.json", :method => :post
      })
    end

    it "cancel an open task" do
      user_game = FactoryGirl.create(:user_game_with_3_tasks_2_open)
      user_task = user_game.user_tasks[1] # The 1st task is "completed", 2nd and 3rd open

      sign_in_as user_game.user      
      post "/api/v1/my/tasks/#{user_task.task_id}/cancel.json"

      response.status.should == 200
      json = JSON.parse response.body
      json['task']['playing_task']['state'].should == "canceled"
    end

    it "cancel a started task" do
      user_game = FactoryGirl.create(:user_game_with_3_tasks_1_started_1_open)
      user_task = user_game.user_tasks[1] # The 1st task is "completed", 2nd started, 3rd open
      sign_in_as user_game.user
      post "/api/v1/my/tasks/#{user_task.task_id}/cancel.json"
      response.status.should == 200
      json = JSON.parse response.body
      json['task']['playing_task']['state'].should == "canceled"
    end

    it "cancel a completed task does not throw an error" do
      user_game = FactoryGirl.create(:user_game_with_3_tasks_2_open)
      user_task = user_game.user_tasks[0] # The 1st task is "completed", 2nd and 3rd open

      sign_in_as user_game.user
      post "/api/v1/my/tasks/#{user_task.task_id}/cancel.json"

      response.status.should == 200
      json = JSON.parse response.body
      json['task']['playing_task']['state'].should == "completed"
    end

  end

  describe "Start a User's Game Task" do

    it "generate a route" do
      assert_generates("/api/v1/my/tasks/1/start.json", {
        :controller => 'api/v1/account/tasks', :action => "start",
        :task_id => "1", :format => :json
      })
    end

    it "recognize route" do
      assert_recognizes({
        :controller => 'api/v1/account/tasks', :action => "start",
        :task_id => "1", :format => "json"
      }, {
        :path => "/api/v1/my/tasks/1/start.json", :method => :post
      })
    end

    it "start first open task" do
      user_game = FactoryGirl.create(:user_game_with_3_open_tasks)
      user_task = user_game.user_tasks[0]
      sign_in_as user_game.user
      post "/api/v1/my/tasks/#{user_task.task_id}/start.json"

      response.status.should == 200
      json = JSON.parse response.body
      json['task']['playing_task']['state'].should == "started"
    end

    it "starting a started task does not throw an error" do
      user_game = FactoryGirl.create(:user_game_with_3_tasks_1_started_1_open)
      user_task = user_game.user_tasks[1] # the started task

      sign_in_as user_game.user
      post "/api/v1/my/tasks/#{user_task.task_id}/start.json"

      response.status.should == 200
      json = JSON.parse response.body
      json['task']['playing_task']['state'].should == "started"
    end
  end

  describe "games" do
    let(:user) { FactoryGirl.create(:user_very_experienced) }
    let(:game_1) { FactoryGirl.create(:game) }
    let(:game_2) { FactoryGirl.create(:game) }

    it 'responds with content_type :json' do
      get "/api/v1/my/games.json"
      response.content_type.should == "application/json"
    end

    it 'error if not logged in' do
      get "/api/v1/my/games.json"
      response.status.should == 401
    end

    it 'return list with 2 games' do
      sign_in_as user

      user.buy_game! game_1
      user.buy_game! game_2

      get "/api/v1/my/games.json"
      json = JSON.parse response.body
      json.should have_key 'games'
      json['games'].count.should == 2
    end

    it 'return empty list' do
      sign_in_as user
      get "/api/v1/my/games.json"
      json = JSON.parse response.body
      json.should have_key 'games'
      json['games'].count.should == 0
    end
  end

  describe "game" do
    let(:user) { FactoryGirl.create(:user_very_experienced) }
    let(:game) { FactoryGirl.create(:game) }

    it 'show detail responds with content_type :json' do
      get "/api/v1/my/games/#{game.id}.json"
      response.content_type.should == "application/json"
    end

    context 'when not logged in' do
      it 'error if not logged in' do
        get "/api/v1/my/games/#{game.id}.json"
        response.status.should == 401
      end
    end

    context 'when logged in' do
      
      it 'game detail is valid json' do
        sign_in_as user
        user.buy_game! game
        get "/api/v1/my/games/#{game.id}.json"
        json = JSON.parse response.body
        json['game'].should have_key 'playing_game'
        json['game']['playing_game'].should have_key 'game_id'
        json['game']['playing_game'].should have_key 'state'
      end

      it 'set privacy to community succeeds' do
        sign_in_as user
        user.buy_game! game
        put "/api/v1/my/games/#{game.id}/privacy.json", feed_visibility: UserGame::Visibility::FRIENDS
        json = JSON.parse response.body
        response.status.should == 200
        json['success'].should == true
      end

      it 'set privacy to community fails if user is less than 15 years old' do
        user = FactoryGirl.create(:fifteen_year_old)
        sign_in_as user
        user.buy_game! game
        put "/api/v1/my/games/#{game.id}/privacy.json", feed_visibility: UserGame::Visibility::COMMUNITY
        json = JSON.parse response.body
        response.status.should == 200
        json['success'].should == false
      end
    end
  end

  describe 'user profile add facebook data' do
    let(:user) {FactoryGirl.create(:user)}

    context 'when not logged in' do
      it 'error if not logged in' do
        post "/api/v1/my/profile/add_facebook_id.json", facebook_id: '123456789'
        response.status.should == 401
      end
    end

    context 'when logged in' do
      before(:each) do
        sign_in_as user
      end

      it 'adds facebook_id to the user if id is not set already' do
        post "/api/v1/my/profile/add_facebook_id.json", facebook_id: '123456789'
        response.status.should == 200;
        json = JSON.parse response.body
        json.has_key?('success').should be_true
        json.has_key?('facebook_id').should be_true
        json['facebook_id'].should_not be_nil
      end

      it 'sends a notification to user if a facebook friend signed up' do
        user.facebook_id = '123456789'
        user.save
        friend_1 = FactoryGirl.create(:user, facebook_id: '111111111')
        friend_2 = FactoryGirl.create(:user, facebook_id: '222222222')

        post "/api/v1/my/profile/facebook_friends.json", facebook_friends: ['111111111', '222222222']
        
        response.status.should == 200
        json = JSON.parse response.body
        json.has_key?('success').should be_true
        json['success'].should be_true
        json.has_key?('friends').should be_true

        feed_entries = FeedItem.where(:sender_id => user.id)
        feed_entries.count.should == 1
        feed_entries.first.receiver_ids.count.should == 2
      end

      it 'sends no notification to user if no friends found, show error message instead' do
        user.facebook_id = '123456789'
        user.save

        post "/api/v1/my/profile/facebook_friends.json", facebook_friends: ['33333333']
        
        response.status.should == 200
        json = JSON.parse response.body
        json.has_key?('success').should be_true
        json['success'].should be_false
        json.has_key?('message').should be_true

        feed_entries = FeedItem.where(:sender_id => user.id)
        feed_entries.count.should == 0
      end

      it 'creates friendships when facebook-friend signs in on rylyty',  vcr:true do
        fb_app_id = '123456789356813'
        fb_secrete =  'huh2e6m12345678999e123f3dxw123s1'
        
        if VCR.current_cassette.recording?
          fb_app_id = ENV['FB_APP_ID']
          fb_secrete = ENV['FB_SECRET']
        end

        test_users = Koala::Facebook::TestUsers.new(:app_id => fb_app_id, :secret => fb_secrete)

        fb_users = test_users.list
        fb_rylyty_user = fb_users.delete_at 0
        # this is a bit hacky, but I do not want to delete my fb-user-network all the time
        test_users.create_network(4, true, 'offline_access,read_stream') unless fb_users.count > 1
      
        user_fb_ids = []
        users = []

        fb_users.each do |user| 
          users << user = FactoryGirl.create(:user, facebook_id: user['id'])
          user_fb_ids << user.facebook_id
        end
        
        fb_user = FactoryGirl.create(:user, facebook_id: fb_rylyty_user['id'])
        sign_in_as fb_user

        expect {
          post "/api/v1/my/profile/facebook_friends.json", facebook_friends: user_fb_ids
        }.to change{Friendship.count}.by(user_fb_ids.count)
      end

      it 'throws no error if Friendship cannot be creates', vcr:true do
        fb_app_id = '123456789356813'
        fb_secrete =  'huh2e6m12345678999e123f3dxw123s1'
        
        if VCR.current_cassette.recording?
          fb_app_id = ENV['FB_APP_ID']
          fb_secrete = ENV['FB_SECRET']
        end

        test_users = Koala::Facebook::TestUsers.new(:app_id => fb_app_id, :secret => fb_secrete)
        fb_users = test_users.list
        fb_rylyty_user = fb_users.delete_at 0
        fb_rylyty_user_2 = fb_users.delete_at 1

        fb_user = FactoryGirl.create(:user, facebook_id: fb_rylyty_user['id'])
        fb_user_2 = FactoryGirl.create(:user, facebook_id: fb_rylyty_user_2['id'])
        FactoryGirl.create(:friendship, friend: fb_user_2, user: fb_user)
        
        user_fb_ids = []
        users = []

        fb_users.each do |user| 
          users << user = FactoryGirl.create(:user, facebook_id: user['id'])
          user_fb_ids << user.facebook_id
        end
      
        sign_in_as fb_user

        expect {
          post "/api/v1/my/profile/facebook_friends.json", facebook_friends: user_fb_ids + [fb_rylyty_user_2['id']]
        }.to_not raise_error

      end

      it 'creates no friendships when no-facebook-friend signs in on rylyty' do   
        expect {
          post "/api/v1/my/profile/facebook_friends.json", facebook_friends: []
        }.to change{Friendship.count}.by(0)
      end
    end
  end
end