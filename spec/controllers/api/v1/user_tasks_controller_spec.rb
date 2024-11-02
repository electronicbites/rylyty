require 'spec_helper'

describe Api::V1::UserTasksController do

  context "like user_tasks " do
    render_views
    let(:user_task) { FactoryGirl.create(:user_task_verified) }
    let(:user) {user_task.user}

    describe '#post like' do
      before(:each) do
        sign_in :user, user
      end

      it 'should return success for a newly liked task' do
        post :like, {
          id: user_task.task.id,
          user_id: user.id,
          format: :json
        }
        json = JSON.parse response.body
        json['success'].should be_true
        json['message'].should be_nil
      end

      it 'should return success + message for an already liked task' do
        #like user_task before liking it a second time
        FactoryGirl.create(:like, user_id: user.id, user_task_id: user_task.id)
        post :like, {
          id: user_task.task.id,
          user_id: user.id,
          format: :json
        }
        json = JSON.parse response.body
        json['success'].should be_false
        json['message'].should match 'Das hast du schon mal gemacht.'
      end

      it 'should return false if user !exist' do
        post :like, {
          id: user_task.task.id,
          user_id: 4711111,
          format: :json
        }
        json = JSON.parse response.body
        json['success'].should be_false
      end

      it 'should return false + msg to uncompleted user_task' do
        uncompleted_user_task = FactoryGirl.create(:user_task_started, user: user)
        post :like, {
          id: uncompleted_user_task.task.id,
          user_id: user.id,
          format: :json
        }
        json = JSON.parse response.body
        json['success'].should be_false
        json['message'].should match 'Diesen Beweis kann man noch nicht gut finden.'
      end
    end


    describe '#post unlike' do
      before(:each) do
        sign_in :user, user
      end

      it 'should return success if like was destroyed successfully' do
        #like user_task before unliking it
        FactoryGirl.create(:like, user_id: user.id, user_task_id: user_task.id)
        post :unlike, {
          id: user_task.task.id,
          user_id: user.id,
          format: :json
        }
        json = JSON.parse response.body
        json['success'].should be_true
        json['message'].should be_nil
      end

      it 'should return success + message if user_task exists but wasn`t liked' do
        post :unlike, {
          id: user_task.task.id,
          user_id: user.id,
          format: :json
        }
        json = JSON.parse response.body
        json['success'].should be_true
        json['message'].should match "Noch findet niemand den Beweis gut."
      end

      it 'should return true if user !exist' do
        post :unlike, {
          id: user_task.task.id,
          user_id: 4711,
          format: :json
        }
        json = JSON.parse response.body
        json['success'].should be_true
      end
    end


    describe '#post like/unlike to !existing user_task' do
      before(:each) do
        sign_in :user, user
      end
      
      it 'should return false to like' do
        post :like, {
          id: 4711,
          user_id: user.id,
          format: :json
        }
        json = JSON.parse response.body
        json['success'].should be_false
        json['message'].should match 'Der Beweis wurde nicht gefunden.'
      end

      it 'should return success to unlike' do
        post :unlike, {
          id: 4711,
          user_id: user.id,
          format: :json
        }
        json = JSON.parse response.body
        json['success'].should be_true
        json['message'].should match 'Der Beweis wurde nicht gefunden.'
      end
    end

    describe 'show likes' do
      let(:like) {FactoryGirl.create(:like)}
      let(:owner) {like.user_task.user}
      let(:liker) {like.user}
      
      before(:each) do
        sign_in :user, liker
      end
  
      it 'should show likes and my likes of other users user_tasks' do
        get :index, {
          format: :json,
          user_id: owner.id.to_s
        }
        json = parse_json['tasks']
        json.size.should == 1
        
        json.first.should have_key 'playing_task'
        json.first['playing_task'].should have_key 'liked'
        json.first['playing_task']['liked'].should == true
        json.first['playing_task'].should have_key 'likes'
        json.first['playing_task']['likes'].should == 1
      end
    end
  end
end
