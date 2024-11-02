require 'spec_helper'

describe Api::V1::Account::TasksController do

  describe "user with a diverse game" do
    render_views

    let(:user) { FactoryGirl.create(:user) }
    let(:game) {
      FactoryGirl.create(:game, tasks: [
        FactoryGirl.create(:photo_task), FactoryGirl.create(:multiple_choice_task), FactoryGirl.create(:question_task)
      ])
    }

    let(:another_game) {
      FactoryGirl.create(:game, tasks: [
        FactoryGirl.create(:photo_task), FactoryGirl.create(:multiple_choice_task), FactoryGirl.create(:question_task)
      ])
    }

    let(:unplayable_game) {
      FactoryGirl.create(:game, restriction_points: 500, min_points_required: 500, tasks: [
        FactoryGirl.create(:question_task)
      ])
    }

    before(:each) do
      sign_in :user, user
      user.buy_game! game
      user.games.should include game
      user.tasks.should include *game.tasks
    end
    
    it "respond with 404 for non-existing task id" do
      invalid_id = Task.order(:id).last.id + 1
      get :show, id: invalid_id, format: :json

      json = parse_json
      response.status.should == 404
      json.should have_key 'success'
      json.should have_key 'message'
      json['success'].should == false
      json['message'].should_not be_empty
    end

    it "respond with 404 for an other task id" do
      invalid_id = another_game.tasks.first.id
      get :show, id: invalid_id, format: :json

      json = parse_json
      response.status.should == 404
      json.should have_key 'success'
      json.should have_key 'message'
      json['success'].should == false
      json['message'].should_not be_empty
    end

    it "answering a photo_task should switch state to completed" do
      task       = user.tasks.where(type: 'PhotoTask').first
      user_task  = user.user_tasks.where(task_id: task.id).first

      user_task.start
      user_task.save
      user_task.state.should == 'started'

      expect {
        post :answer, {
          format: :json,
          task_id: task.id,
          answer_with: {
            photo: fixture_file_upload(Rails.root + 'spec/rails.png', 'image/png')
          }
        }
      }.to change { user_task.reload.state }.from('started').to('completed')
    end

    it "cannot start a task if game is not playable" do
      user.buy_game! unplayable_game
      task = unplayable_game.tasks.first
      user_task = user.user_tasks.where(task_id: task.id).first    
      expect{
        post :answer, {
          format: :json,
          task_id: task.id,
          answer_with: {
            answer: "Sure, this rocks!"
          }
        }
      }.not_to change{user_task.reload.state}.from('started').to('completed')
      parse_json['success'].should be_false
    end

    context 'one task to complete' do
      let (:user_game) {FactoryGirl.create(:user_game_with_1_open_tasks, user: user)}
      let (:user_task) {user_game.user_tasks.first}
      let (:task) {user_task.task}
      let (:badge) {FactoryGirl.create(:badge)}

      it "uploading the photo should complete the task" do
        post :answer, {
          format: :json,
          task_id: task.id,
          answer_with: {
            photo: fixture_file_upload(Rails.root + 'spec/rails.png', 'image/png')
          }
        }
        user_task.reload.should be_completed
      end

      it "after finishing the last task, the game should be completed" do
        post :answer, {
          format: :json,
          task_id: task.id,
          answer_with: {
            photo: fixture_file_upload(Rails.root + 'spec/rails.png', 'image/png')
          }
        }
        user_game.reload.should be_completed
      end

      it "completing the game when answering should return rewards for the game plus for the task" do
        post :answer, {
          format: :json,
          task_id: task.id,
          answer_with: {
            photo: fixture_file_upload(Rails.root + 'spec/rails.png', 'image/png')
          }
        }
        parse_json['task']['playing_task']['reward']['task_points'].should == task.points
        parse_json['task']['playing_task']['reward']['game_points'].should == user_game.game.points
      end


      it "when game has a badge it should also be return as a reward" do
        game = user_game.game
        game.add_reward_badge badge
        game.reward_badge.should be_present

        post :answer, {
          format: :json,
          task_id: task.id,
          answer_with: {
            photo: fixture_file_upload(Rails.root + 'spec/rails.png', 'image/png')
          }
        }
        reward_badge = JSON.parse parse_json['task']['playing_task']['reward']['game_reward_badge']
        reward_badge['title'].should == badge.title
      end
    end

    it "answers a photo_task and adds a comment" do
      task       = user.tasks.where(type: 'PhotoTask').first
      user_task  = user.user_tasks.where(task_id: task.id).first

      user_task.start
      user_task.save
      user_task.state.should == 'started'

      expect {
        post :answer, {
          format: :json,
          task_id: task.id,
          answer_with: {
            photo: fixture_file_upload(Rails.root + 'spec/rails.png', 'image/png')
          }
        }
      }.to change { user_task.reload.state }.from('started').to('completed')

      expect {
        put :update, {
          format: :json,
          id: task.id,
          comment: 'my personal comment to the task'
        }
      }.to change { user_task.reload.comment }.from(nil).to('my personal comment to the task')
    end

    it "answers a multiple choice task" do
      task      = user.tasks.where(type: 'MultipleChoiceTask').first
      user_task = user.user_tasks.where(task_id: task.id).first

      user_task.start
      user_task.save

      expect {
        post :answer, {
          format: :json,
          task_id: task.id,
          answer_with: {
            answers: { "0" => [1], "1" => ["0", "1"], 2 => ["2"] }
          }
        }
      }.to change { user_task.reload.state }.from('started').to('completed')
    end


    it "answers a multiple choice task with single answers" do
      task      = user.tasks.where(type: 'MultipleChoiceTask').first
      user_task = user.user_tasks.where(task_id: task.id).first

      user_task.start
      user_task.save

      expect {
        post :answer, {
          format: :json,
          task_id: task.id,
          answer_with: {
            answers: { "0" => "1", "1" => ["0", "1"], 2 => "2" }
          }
        }
      }.to change { user_task.reload.state }.from('started').to('completed')
    end

    it "answers a question task" do
      task      = user.tasks.where(type: 'QuestionTask').first
      user_task = user.user_tasks.where(task_id: task.id).first

      user_task.start
      user_task.save
      user_task.state.should == 'started'

      expect {
        post :answer, {
          format: :json,
          task_id: task.id,
          answer_with: {
            answer: "Sure, this rocks!"
          }
        }
      }.to change { user_task.reload.state }.from('started').to('completed')
    end

    it "answers a task twice returns an errors message" do
      task      = user.tasks.where(type: 'QuestionTask').first
      user_task = user.user_tasks.where(task_id: task.id).first

      user_task.start
      user_task.save
      user_task.state.should == 'started'

      expect {
        post :answer, {
          format: :json,
          task_id: task.id,
          answer_with: {
            answer: "Sure, this rocks!"
          }
        }
      }.to change { user_task.reload.state }.from('started').to('completed')

      post :answer, {
        format: :json,
        task_id: task.id,
        answer_with: {
          answer: "Sure, this rocks!"
        }
      }

      parse_json['success'].should be_false
    end

    context "with multiple choice taskt having string values for integers" do
      let(:game) {
        FactoryGirl.create(:game, tasks: [
          FactoryGirl.create(:multiple_choice_task_with_string_values)
        ])
      }
      it "answers a multiple choice task" do
        task      = user.tasks.where(type: 'MultipleChoiceTask').first
        user_task = user.user_tasks.where(task_id: task.id).first

        user_task.start
        user_task.save
        user_task.state.should == 'started'

        expect {
          post :answer, {
            format: :json,
            task_id: task.id,
            answer_with: {
              answers: { "0" => [1], "1" => ["0", "1"], 2 => ["2"] }
            }
          }
        }.to change { user_task.reload.state }.from('started').to('completed')
      end
    end

    context "with multiple choice taskt having string values for integers and omitted false values" do
      let(:game) {
        FactoryGirl.create(:game, tasks: [
          FactoryGirl.create(:multiple_choice_task_with_string_values_omitted_false)
        ])
      }
      it "answers a multiple choice task" do
        task      = user.tasks.where(type: 'MultipleChoiceTask').first
        user_task = user.user_tasks.where(task_id: task.id).first

        user_task.start
        user_task.save
        user_task.state.should == 'started'

        expect {
          post :answer, {
            format: :json,
            task_id: task.id,
            answer_with: {
              answers: { "0" => [1], "1" => ["0", "1"], 2 => ["2"] }
            }
          }
        }.to change { user_task.reload.state }.from('started').to('completed')
      end
    end
  end

  context '#answer with photo' do
    let(:user) {FactoryGirl.create(:user)}
    let(:user_game) {
      FactoryGirl.create(:user_game,
        user: user,
        user_tasks: FactoryGirl.build_list(:user_task_completed, 1, user: user) +
          FactoryGirl.build_list(:user_task, 2, user: user, type: 'PhotoAnswer')
      )
    }
    let(:task) {user_game; user.tasks.last}
    let(:user_task) {user.user_tasks.where(task_id: task.id).first}

    before(:each) do
      sign_in :user, user
      user_task.start
      user_task.save
      user_task.state.should == 'started'
    end

    it 'should persist the images data' do
      post :answer, {
        format: :json,
        task_id: task.id.to_s,
        answer_with: {
          photo: fixture_file_upload(Rails.root + 'spec/rails.png', 'image/png')
        }
      }
      user_task.reload.photo.should_not be_nil
    end
  end

  context 'likes' do
    render_views

    let(:like) {FactoryGirl.create(:like)}
    let(:owner) {like.user_task.user}
    
    before(:each) do
      sign_in :user, owner
    end

    it 'show likes' do
      get :show, {
        format: :json,
        id: like.user_task.task.id.to_s
      }
      json = parse_json['task']['playing_task']
      json.should have_key 'likes'
      json['likes'].should == 1
    end
  end

end
