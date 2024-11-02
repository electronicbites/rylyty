require 'spec_helper'

describe '/api/v1/games/game_id/tasks'  do
  let(:game) { FactoryGirl.create(:game) }
  let(:user) { FactoryGirl.create(:user) }

  context 'when not logged in' do
    it 'respond with 401' do
      get "/api/v1/games/#{game.id}/tasks"
      response.status == 401
    end
  end

  context 'when logged in' do

    before(:each) do
      sign_in_as user
    end

    describe 'task list' do

      it 'respond with 200' do
        get "/api/v1/games/#{game.id}/tasks.json"
        response.status == 200
      end

      it 'responds with content_type json' do
        get "/api/v1/games/#{game.id}/tasks.json"
        response.content_type.should == "application/json"
      end

      it 'returns a valid json response if game exists' do
        get "/api/v1/games/#{game.id}/tasks.json"
        json = JSON.parse response.body
        json.should have_key 'tasks'
        json_tasks = json['tasks']
        json_tasks.length.should == 3
        json_tasks.each { |t|
          t.has_key?('user_task_viewable').should be_true
        }
      end

      it 'return 404 if game could not be found' do
        get "/api/v1/games/12345/tasks.json"
        response.status == 404
      end

    end
  end
end

describe 'api/v1/task/123.json' do

  let(:user) { FactoryGirl.create(:user, email: 'mytest@example.com')}

  context 'when not logged in' do
    it 'respond with 401' do
      task = create_photo_task_completed_by_ten_users
      get "/api/v1/tasks/#{task.id}.json"
      response.status == 401
    end
  end

  context 'when logged in' do

    before(:each) do
      sign_in_as user
    end

    it 'responds with 200' do
      task = create_photo_task_completed_by_ten_users
      get "/api/v1/tasks/#{task.id}.json"
      response.status.should == 200
    end

    it 'shows the 10 latest photo proofs if task is a photo_task' do
      task = create_photo_task_completed_by_ten_users
      get "/api/v1/tasks/#{task.id}.json"
      json = JSON.parse response.body
      json.has_key?('task').should be_true
      json['task'].has_key?('user_tasks').should be_true
      json['task']['user_tasks'].count.should == 10
      json['task']['user_tasks'].each { |t|
        t['proof_type'].should == "PhotoAnswer"
        t['approval_state'].should_not == "blocked"
      }
    end

    it 'list is not including blocked tasks' do
      task = create_photo_task_completed_by_ten_users_five_blocked
      get "/api/v1/tasks/#{task.id}.json"
      json = JSON.parse response.body
      json.has_key?('task').should be_true
      json['task'].has_key?('user_tasks').should be_true
      json['task']['user_tasks'].count.should == 5
      json['task']['user_tasks'].each { |t|
        t['proof_type'].should == "PhotoAnswer"
        t['approval_state'].should_not == "blocked"
      }
    end

    it 'should return an empty answer list if no answer exists' do
      task = FactoryGirl.create(:photo_task)
      get "/api/v1/tasks/#{task.id}.json"
      json = JSON.parse response.body
      json.has_key?('task').should be_true
      json['task']['user_tasks'].count.should == 0
    end
  end
end