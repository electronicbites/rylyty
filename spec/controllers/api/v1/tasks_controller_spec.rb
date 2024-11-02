require 'spec_helper'

describe Api::V1::TasksController do
  render_views

  describe '#get index' do
    let(:game) { FactoryGirl.create(:game) }


    before(:each) do
      sign_in :user, FactoryGirl.create(:user)
      game.tasks.should be_present
    end

    it 'should return short_description' do
      get :index, game_id: game.id, format: :json
      json = ActiveSupport::JSON.decode(response.body)
      json.should have_key 'tasks'
      json['tasks'].first['short_description'].should == game.tasks.first.short_description
    end
  end

  describe '#get show' do
    let(:game) { FactoryGirl.create(:photo_game) }
    let(:task) { game.tasks.first }
    let(:user) {FactoryGirl.create(:user)}


    before(:each) do
      sign_in :user, user
    end

    it 'should return description and short_description' do
      get :show, game_id: game.id, id: task.id, format: :json
      json = parse_json
      json['task']['description'].should == task.description
      json['task']['short_description'].should == task.short_description
    end

    it 'should return image urls for the task' do
      get :show, game_id: game.id, id: task.id, format: :json
      parse_json['task']['thumb'].should == task.icon.url(:thumb)
    end

    it 'should return the timeout for timedtasks' do
      task.timeout_secs = 3600
      task.save
      get :show, game_id: game.id, id: task.id, format: :json
      parse_json['task']['time_limit'].should == 3600
    end

    it 'should return that this task/game is playable' do
      get :show, game_id: game.id, id: task.id, format: :json
      parse_json['task']['playable'].should == true
    end

    it "should not return a playing_task node" do
      get :show, game_id: game.id, id: task.id, format: :json
      parse_json['task'].should_not have_key 'playing_task'
    end

    context "user_tasks" do
      before(:each) do
        another_user = FactoryGirl.create(:user)
        user_game = FactoryGirl.create(:user_game, game: game, user: another_user)
        @user_task = FactoryGirl.create(:user_task_verified, task: task, user_game: user_game)
      end

      it "returns reward object with points, credits and badge" do
        get :show, game_id: game.id, id: task.id, format: :json
        json = parse_json
        json['task']['user_tasks'].size.should == 1
        json['task']['user_tasks'].first.should have_key 'reward'
        rewardhash = ActiveSupport::JSON.decode json['task']['user_tasks'].first['reward']
        rewardhash.size.should == 2
        rewardhash.should have_key 'game_points'
      end
    end
    

    context 'user is playing this task' do
      before(:each) do
        user.buy_game! game
      end

      it 'should return state for bought tasks/games' do
        get :show, game_id: game.id, id: task.id, format: :json
        parse_json['task']['playing_task']['state'].should == 'open'
      end

      it 'should return state for started tasks' do
        user.user_tasks.find_by_task_id(task.id).start!
        get :show, game_id: game.id, id: task.id, format: :json
        parse_json['task']['playing_task']['state'].should == 'started'
      end

      it "should return a playing_task node" do
        get :show, game_id: game.id, id: task.id, format: :json
        parse_json['task'].should have_key 'playing_task'
      end
    end

    context 'advertised user_tasks' do
      let(:user_task) {FactoryGirl.create(:completed_photo_answer)}
      let(:task) {user_task.task}

      it 'should return sample images of other user answers' do
        task.find_latest_advertised_answers.should be_present
        get :show, id: task.id, format: :json
        parse_json['task']['user_tasks'].size.should == 1
        parse_json['task']['user_tasks'].first.should have_key('thumb')
        parse_json['task']['user_tasks'].first.should have_key('by_friend')
      end
    end

    context "with multiple choice task" do

      let(:game) {FactoryGirl.create(:multiple_choice_game, costs: 23)}
      let(:task) { game.tasks.first }
      let(:user) {FactoryGirl.create(:user)}

      before(:each) do
        sign_in :user, user
      end

      it '#show list answer-options' do
        get :show, id: task.id, format: :json
        json = parse_json

        json['task']['description'].should == task.description
        json['task']['short_description'].should == task.short_description
        json['task'].should have_key 'questions'
        json['task']['questions'].each { |q|
          q.should have_key 'points'
          q.should have_key 'question'
          q.should have_key 'options'
          q['options'].each { |o|
            o.should have_key 'order'
            o.should have_key 'answer'
            o.should have_key 'check'
          }
        }
      end

      it '#list answer-options should include multichoice infos' do
        get :index, game_id: game.id, format: :json
        json = parse_json
        json['tasks'].should be_present

        json['tasks'].size.should == game.tasks.size
        first_task = json['tasks'].first

        first_task.should have_key 'task_type'
        first_task['task_type'].should == "MultipleChoiceTask"

        first_task.should have_key 'questions'
        first_task['questions'].each { |q|
          q.should have_key 'points'
          q.should have_key 'question'
          q.should have_key 'options'
          q['options'].each { |o|
            o.should have_key 'order'
            o.should have_key 'answer'
            o.should have_key 'check'
          }
        }
      end

      context "with string values for Integers (#bug 39935151)" do
        render_views
        let(:game) do
          FactoryGirl.create(:multiple_choice_game,
            costs: 23,
            tasks: [ FactoryGirl.create(:multiple_choice_task_with_string_values) ]
          )
        end
        let(:task) { game.tasks.first }

        it "should not throw an error" do
          expect {
            get :index, game_id: game.id, format: :json
          }.to_not raise_error
        end
      end

      context "with string values for integers and omitted false" do
        render_views
        let(:game) do
          FactoryGirl.create(:multiple_choice_game,
            costs: 23,
            tasks: [ FactoryGirl.create(:multiple_choice_task_with_string_values_omitted_false) ]
          )
        end
        let(:task) { game.tasks.first }

        it "should not throw an error" do
          expect {
            get :index, game_id: game.id, format: :json
          }.to_not raise_error
        end
      end
    end
  end
end
