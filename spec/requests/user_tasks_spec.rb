# encoding: UTF-8
require 'spec_helper'

describe 'api/v1/users/tasks' do

  describe '#get index' do
    let(:user) {FactoryGirl.create(:user)}
    let(:user_game) {
      FactoryGirl.create(:user_game,
        user: user,
        user_tasks: FactoryGirl.build_list(:user_task_completed, 1, user: user) +
          FactoryGirl.build_list(:user_task, 2, user: user, type: 'PhotoAnswer')
      )
    }

    before(:each) do
      sign_in_as user
    end

    it 'list 3 tasks' do
      get "/api/v1/users/#{user_game.user.id}/tasks.json"
      json = ActiveSupport::JSON.decode(response.body)
      json.should_not be_empty
      json.should have_key 'tasks'
      json['tasks'].count.should == 3
    end

    it 'include user_task information' do
      get "/api/v1/users/#{user_game.user.id}/tasks.json"
      json = ActiveSupport::JSON.decode(response.body)
      json['tasks'].each { |task|
        task.should have_key 'playing_task'
        task['playing_task'].should_not be_empty
      }
    end
  end

  describe 'report a user_task' do
    
    let(:user) {FactoryGirl.create(:user)}
    let(:another_user) {FactoryGirl.create(:user)}
    let(:user_game) {
      FactoryGirl.create(:user_game,
        user: another_user,
        user_tasks: FactoryGirl.build_list(:user_task_completed, 3, user: another_user)
      )
    }

    context 'when logged in' do

      before(:each) do
        sign_in_as user
      end

      it 'return status 200' do
        user_task = user_game.user_tasks[0]
        post "/api/v1/users/#{user.id}/tasks/#{user_task.id}/report.json"
        response.status.should == 200
      end

      it 'returns a valid json format' do
        user_task = user_game.user_tasks[1]
        post "/api/v1/users/#{user.id}/tasks/#{user_task.id}/report.json"
        #user_task.reload.approval_state.should == UserTask::ApprovalStates::REPORTED
        json = JSON.parse response.body
        json.should have_key 'user_task'
        json['user_task'].should have_key 'task_id'
        json['user_task'].should have_key 'user_id'
        json['user_task'].should have_key 'reporting_user'
      end

      it 'set approval_state to blocked' do
        user_task = user_game.user_tasks[2]
        post "/api/v1/users/#{user.id}/tasks/#{user_task.id}/block.json"
        user_task.reload.approval_state.should == UserTask::ApprovalStates::BLOCKED
      end

      it 'returns a succes state failes' do
        post "/api/v1/users/#{user.id}/tasks/123/report.json"
        json = JSON.parse response.body
        json.should have_key 'success'
        json['success'].should == false
      end

    end
  end

  describe "answer a task" do

    let(:user) {FactoryGirl.create(:user)}
    let(:another_user) {FactoryGirl.create(:user)}
    let(:user_game) {
      user_game = FactoryGirl.create(:user_game,
        user: another_user,
        user_tasks: FactoryGirl.build_list(:photo_answer, 3, user: another_user)
      )
    }
    let(:photo_answer) { user_game.user_tasks.first }

    context "answering non-timed task" do
      before(:each) do
        sign_in_as another_user
      end

      it "completes an open photo answer" do
        post "/api/v1/my/tasks/#{photo_answer.task_id}/answer.json", answer_with: {photo: fixture_file_upload(Rails.root + 'spec/rails.png', 'image/png')}
        parse_json['task']['playing_task']['state'].should == 'completed'
        photo_answer.reload.state.should == 'completed'
      end
    end

    context "answering not valid user task" do
      let(:photo_answer) { user_game.user_tasks.first }

      before(:each) do
        sign_in_as user
      end

      it "error when answering a task for a not user_game " do
        post "/api/v1/my/tasks/#{photo_answer.task_id}/answer.json", answer_with: {photo: fixture_file_upload(Rails.root + 'spec/rails.png', 'image/png')}
        parse_json['message'].should match 'Du mußt das Spiel kaufen, bevor du den Task starten kannst.'
      end

      it "error when starting a task for a not user_game " do
        post "/api/v1/my/tasks/#{photo_answer.task_id}/start.json", answer_with: {photo: fixture_file_upload(Rails.root + 'spec/rails.png', 'image/png')}
        parse_json['message'].should match 'Du mußt das Spiel kaufen, bevor du den Task starten kannst.'
      end
    end

    context "fetch answered task information" do
      before(:each) do
        photo_answer.answer_with({photo: fixture_file_upload(Rails.root + 'spec/rails.png', 'image/png')})
        sign_in_as user
      end

      it "shows the proof date" do
        get "/api/v1/users/#{another_user.id}/tasks.json"
        task_json = parse_json['tasks'].find { |obj| obj['id'] == photo_answer.task.id }

        task_json.should have_key('playing_task')
        task_json['playing_task'].should have_key('proof_timestamp')
        
        proof_timestamp = task_json['playing_task']['proof_timestamp']
        proof_timestamp.should be_present
        DateTime.strptime(proof_timestamp.to_s, "%s") == photo_answer.reload.finished_at
      end

      it "has a empty proof date for not answered task" do
        get "/api/v1/users/#{another_user.id}/tasks.json"
        task_json = parse_json['tasks'].find { |obj| obj['id'] != photo_answer.task.id }

        task_json.should have_key('playing_task')
        task_json['playing_task'].should have_key('proof_timestamp')
        
        proof_timestamp = task_json['playing_task']['proof_timestamp']
        proof_timestamp.should_not be_present
      end
    end
  end
end