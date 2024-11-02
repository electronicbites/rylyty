  require 'spec_helper'

  describe 'feeds' do
    let(:user) { FactoryGirl.create(:user) }
    let(:another_user) { FactoryGirl.create(:user)}
    let(:friend) {FactoryGirl.create(:user)}
    let(:game) {FactoryGirl.create(:photo_game_with_one_task)}

    context 'when changing states' do
      
      before(:each) do
        sign_in_as user
      end

      it 'adds a feed entry after starting a task visible for friends' do
        FactoryGirl.create(:friendship, friend: friend, user: user)
        user_game = FactoryGirl.create(:user_game_with_3_open_tasks, user: user)
        user_task = user_game.user_tasks[1]

        post "/api/v1/my/tasks/#{user_task.task_id}/start.json"
        response.status.should == 200
        feed_item = FeedItem.where(sender_id: user.id)
        feed_item.first.should be
        feed_item.first.receiver_ids.should_not be_nil
        feed_item.first.feedable.should_not be_nil
      end

      it 'adds a feed entry when completing a task' do
        FactoryGirl.create(:friendship, friend: friend, user: user)
        user.buy_game! game
        user_game = user.user_games.first
        task = user_game.user_tasks.first

        post "/api/v1/my/tasks/#{task.task_id}/start.json"
        task.reload.state.should == "started"
        post "/api/v1/my/tasks/#{task.task_id}/answer.json", answer_with: {photo: fixture_file_upload(Rails.root + 'spec/rails.png', 'image/png')}
        task.reload.state.should == "completed"
        task.reload.verification_state.should == "verified"
        feed_item = FeedItem.where(:event_type => 'task_completed').last
        feed_item.receiver_ids.should include(friend.id)
        feed_item.receiver_ids.should_not include(another_user.id)
        feed_item.feedable.should_not be_nil
      end

      it 'adds a feed entry when completing a game' do
        FactoryGirl.create(:friendship, friend: friend, user: user)
        user.buy_game! game
        user_game = user.user_games.first
        task = user_game.user_tasks.first

        post "/api/v1/my/tasks/#{task.task_id}/start.json"
        response.status.should == 200
        post "/api/v1/my/tasks/#{task.task_id}/answer.json", answer_with: {photo: fixture_file_upload(Rails.root + 'spec/rails.png', 'image/png')}
        response.status.should == 200
        task.reload.state.should == "completed"
        task.reload.verification_state.should == "verified"
        user_game.reload.state.should == "completed"
        feed_item = FeedItem.where(:event_type => 'game_completed').last
        feed_item.receiver_ids.should include(friend.id)
        feed_item.receiver_ids.should_not include(another_user.id)
        feed_item.feedable.should_not be_nil
      end

      it 'does not write a feed item if user has no friends and visibility is not set to community' do
        game_one_task = FactoryGirl.create(:photo_game_with_one_task)
        user.buy_game! game_one_task
        user_game = user.user_games.last
        user_game.update_attributes(feed_visibility: 'friends')
        task = user_game.user_tasks.first
        post "/api/v1/my/tasks/#{task.task_id}/start.json"
        task.reload.state.should == "started"
        post "/api/v1/my/tasks/#{task.task_id}/answer.json", answer_with: {photo: fixture_file_upload(Rails.root + 'spec/rails.png', 'image/png')}
        task.reload.state.should == "completed"
        user_game.reload.state.should == "completed"
        feed_item = FeedItem.where(sender_id: user.id)
        feed_item.should be_empty
      end

      it 'does write a feed item if user has no friends but visibility is set to community' do
        game_one_task = FactoryGirl.create(:photo_game_with_one_task)
        user.buy_game! game_one_task
        user_game = user.user_games.last
        task = user_game.user_tasks.first
        post "/api/v1/my/tasks/#{task.task_id}/start.json"
        task.reload.state.should == "started"
        post "/api/v1/my/tasks/#{task.task_id}/answer.json", answer_with: {photo: fixture_file_upload(Rails.root + 'spec/rails.png', 'image/png')}
        task.reload.state.should == "completed"
        user_game.reload.state.should == "completed"
        feed_item = FeedItem.where(sender_id: user.id)
        feed_item.should_not be_empty
      end

    end

    context 'when not logged in' do
      it 'responds with content_type :json' do
        get "/api/v1/my/feeds/games.json"
        response.content_type.should == "application/json"
      end

      it 'error if not logged in' do
        get "/api/v1/my/feeds/games.json"
        response.status.should == 401
      end
    end

    context 'when logged in' do
      
      before(:each) do
        sign_in_as user
      end
      
      it 'returns valid json for started friend_feed_task_item' do
        FactoryGirl.create(:friendship, friend: friend, user: user)
        photo_game = FactoryGirl.create(:photo_game)
        user.buy_game! photo_game
        first_task = user.user_games.first.user_tasks[0]
        post "/api/v1/my/tasks/#{first_task.task_id}/start.json"
        first_task.reload.state.should == "started"
        sign_in_as friend
        get "/api/v1/my/feeds/friends.json?startkey=0"
        response.status.should == 200
        json = JSON.parse response.body
        json.should have_key 'feed_items'
        feed_item = json['feed_items'].first
        feed_item.should have_key 'message'
        feed_item.should have_key 'sender'
        feed_item.should have_key 'feedable'
        feed_item['feedable'].should_not be_empty
        feed_item['feedable']['object']['message'].should_not =~ /translation missing/
        feed_item['thumb'].should_not be_empty
        feed_item['thumb_hi'].should_not be_empty
      end

      it 'get a friend feed with 1 tasks startet 2 tasks completed' do
        FactoryGirl.create(:friendship, friend: friend, user: user)
        photo_game = FactoryGirl.create(:photo_game)

        user.buy_game! photo_game
        first_task = user.user_games.first.user_tasks[0]
        second_task = user.user_games.first.user_tasks[1]
        third_task = user.user_games.first.user_tasks[2]

        post "/api/v1/my/tasks/#{first_task.task_id}/start.json"
        first_task.reload.state.should == "started"
        post "/api/v1/my/tasks/#{first_task.task_id}/answer.json", answer_with: {photo: fixture_file_upload(Rails.root + 'spec/rails.png', 'image/png')}
        first_task.reload.state.should == "completed"

        post "/api/v1/my/tasks/#{second_task.task_id}/start.json"
        second_task.reload.state.should == "started"
        post "/api/v1/my/tasks/#{second_task.task_id}/answer.json", answer_with: {photo: fixture_file_upload(Rails.root + 'spec/rails.png', 'image/png')}
        second_task.reload.state.should == "completed"

        post "/api/v1/my/tasks/#{third_task.task_id}/start.json"
        third_task.reload.state.should == "started"

        sign_in_as friend

        #startkey = Time.now.to_f
        get "/api/v1/my/feeds/friends.json?startkey=0"
        response.status.should == 200
        json = JSON.parse response.body
        json['feed_items'].count.should == 5

      end

      it 'get a friend feed one task started, one task finished and one game finished' do
        FactoryGirl.create(:friendship, friend: friend, user: user)
        game_one_task = FactoryGirl.create(:photo_game_with_one_task)
        user.buy_game! game_one_task
        user_game = user.user_games.last
        single_task = user_game.user_tasks[0]
        post "/api/v1/my/tasks/#{single_task.task_id}/start.json"
        single_task.reload.state.should == "started"
        post "/api/v1/my/tasks/#{single_task.task_id}/answer.json", answer_with: {photo: fixture_file_upload(Rails.root + 'spec/rails.png', 'image/png')}
        single_task.reload.state.should == "completed"
        user_game.reload.state.should == "completed"

        sign_in_as friend

        get "/api/v1/my/feeds/friends.json?startkey=0"
        response.status.should == 200
        json = JSON.parse response.body
        json['feed_items'].count.should == 3
      end

      it 'get a newsfeed item with one user_tasks timed out' do
        user_game = FactoryGirl.create(:user_game_with_1_timed_tasks, user: user)
        user_task = user_game.user_tasks.first
        post "/api/v1/my/tasks/#{user_task.task_id}/start.json"
        Workers::TimedTask.should have_scheduled(user_task.id).at(user_task.times_out_at)
        Workers::TimedTask.perform user_task.id

        get "/api/v1/my/feeds/news.json?startkey=0"
        response.status.should == 200
        json = JSON.parse response.body
        json.should have_key 'feed_items'
        feed_item = json['feed_items'].first
        feed_item.should have_key 'feedable'
        feed_item['feedable']['type'].should <= "UserTask"
        feed_item['feedable']['object']['message'].should_not =~ /translation missing/
      end

      it 'get a newsfeed item, with one task liked' do
        user_task = FactoryGirl.create(:completed_photo_answer, user: user)
        post "/api/v1/users/#{user_task.user.id}/tasks/#{user_task.task.id}/like"
        response.status.should == 200
        FeedItem.all.should_not be_empty

        get "/api/v1/my/feeds/news.json?startkey=0"
        response.status.should == 200
        json = JSON.parse response.body
        json.should have_key 'feed_items'
        feed_item = json['feed_items'].first
        feed_item.should have_key 'event_type'
        feed_item['event_type'] == UserTask::EventTypes::LIKE
        feed_item.should have_key 'feedable'
        feed_item['feedable']['type'].should <= "UserTask"
        feed_item['feedable']['object']['message'].should_not =~ /translation missing/
        feed_item['thumb'].should_not be_empty
        feed_item['thumb_hi'].should_not be_empty
      end

      it 'get a news_feed with when a facebook friend signed up' do
        user.facebook_id = '123456489'
        user.save
        feed_item = FactoryGirl.create(:feed_item, receiver_ids: [user.id], feedable: another_user, sender_id: another_user.id, message: message )

        get "/api/v1/my/feeds/news.json?startkey=0"
        response.status.should == 200
        json = JSON.parse response.body
        json['feed_items'].count.should == 1
        feed_item = json['feed_items'].first
        feed_item['feedable']['object']['message'].should_not =~ /translation missing/ 
      end

      it 'get a news_feed with 5 friends notifications' do
        user.facebook_id = '000123456789'
        user.save
        facebook_ids = []
        friends = []
        feed_items = []

        10.times { friends << FactoryGirl.create(:facebook_user) }
        friends.each { |friend| facebook_ids << friend.facebook_id }
        
        facebook_ids.each do |fb_id| 
          sender = User.where(facebook_id: fb_id).first
          message = {username: sender.username}
          feed_items << FactoryGirl.create(:feed_item, receiver_ids: [user.id], feedable: sender, sender_id: sender.id, message: message )
        end
        
        get "/api/v1/my/feeds/news.json?startkey=0&limit=5"
        response.status.should == 200
        json = JSON.parse response.body

        json.has_key?('feed_items').should be_true
        json['feed_items'].count.should == 5
      end

      it "get a valid news_feed_item when a invitation was accepted" do
        invitee_email = 'foo23@example.com'
        invitation = FactoryGirl.create(:invitation, invited_by: user, email: invitee_email)
        
        new_user = FactoryGirl.create( :user, 
          email: invitee_email,
          username: 'fancy_user_name',
          password: "foo-passw0rd",
          password_confirmation: "foo-passw0rd",
          tos: "true"
        )

        expect{
          invitation.accept! new_user
        }.to change{user.reload.credits}.by(50)
        

        get "/api/v1/my/feeds/news.json?startkey=0"
        response.status.should == 200
        json = JSON.parse response.body
        json.should have_key 'feed_items'
        feed_item = json['feed_items'].first
        feed_item.should have_key 'feedable'
        feed_item.should have_key 'event_type'
        feed_item['event_type'].should == Invitation::EventTypes::INVITE_ACCEPTED
        feed_item['feedable']['type'].should == 'User'
        feed_item['feedable']['object']['message'].should_not =~ /translation missing/
        feed_item['thumb'].should_not be_empty
        feed_item['thumb_hi'].should_not be_empty
      end

      it "get a valiid news_feed_item when a game invitation was received" do
        
        post "api/v1/invitations", {
          friend: friend.id,
          game: game.id
        }

        json = JSON.parse response.body
        json['success'].should be_true

        sign_in_as friend

        get "/api/v1/my/feeds/news.json?startkey=0"
        json = JSON.parse response.body

        json.should have_key 'feed_items'
        feed_item = json['feed_items'].first
        feed_item.should have_key 'feedable'
        feed_item.should have_key 'event_type'
        feed_item['event_type'].should == Invitation::EventTypes::GAME_INVITE_RECEIVED
        feed_item['feedable']['type'].should == 'Game'
        feed_item['feedable']['object']['message'].should_not =~ /translation missing/
        feed_item['thumb'].should_not be_empty
        feed_item['thumb_hi'].should_not be_empty
      end

    end

  end