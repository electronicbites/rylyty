require 'spec_helper'

feature 'playing a game' do

  let(:mission) { FactoryGirl.create(:mission) }
  let(:multiple_choice_game) { FactoryGirl.create(:multiple_choice_game) }
  let(:photo_game) { FactoryGirl.create(:photo_game_with_one_task, points: 25) }

  let(:user) { FactoryGirl.create(:user) }

  scenario 'simple timed multiple_choice_game play roundtrip' do

    multiple_choice_game.missions << mission
    task = multiple_choice_game.tasks.first
    task.timeout_secs = 300
    task.save!
    sign_in_as user
    get "/api/v1/missions/#{mission.id}/games.json"
    json = ActiveSupport::JSON.decode(response.body)
    game = json['games'].last
    game['title'].should be_present
    game['id'].should be_present

    game_id = game['id']
    game_id.should == multiple_choice_game.id

    get "/api/v1/games/#{game_id}.json"
    json = ActiveSupport::JSON.decode(response.body)
    json['game']['id'].should == game_id

    get "/api/v1/games/#{game_id}/tasks.json"
    json = ActiveSupport::JSON.decode(response.body)
    json['tasks'].size.should > 1
    json['tasks'].first['title'].should be_present
    task_id = json['tasks'].first['id']

    expect {
      post "/api/v1/games/#{game_id}/buy.json"
    }.to change{user.reload.user_games.count}.by(1)
    json = ActiveSupport::JSON.decode(response.body)

    user_task = user.user_tasks.find_by_task_id task_id
    user_task.state.should == "open"

    get "/api/v1/my/games.json"
    json = ActiveSupport::JSON.decode(response.body)
    json['games'].size.should == 1
    game = json['games'].last
    game['id'].should == game_id
    game['playing_game'].should be_present


    get "/api/v1/my/tasks/#{task_id}.json"
    json = ActiveSupport::JSON.decode(response.body)


    post "/api/v1/my/tasks/#{task_id}/start.json"
    json = ActiveSupport::JSON.decode(response.body)

    user_task.reload.state.should == "started"

    post "/api/v1/my/tasks/#{task_id}/answer.json", answer_with: {answers: { "0" => [1], "1" => ["0", "1"], 2 => ["2"] }}
    json = ActiveSupport::JSON.decode(response.body)

    user_task.reload.state.should == "completed"
    user_task.reload.verification_state.should == "verified"
    user_task.reload.approval_state.should == "active"

    put "/api/v1/my/tasks/#{task_id}.json", comment: 'my personal comment to this task'
    json = ActiveSupport::JSON.decode(response.body)
    user_task.reload.comment.should_not be_nil
  end


  scenario 'simple photogame play roundtrip' do
    user = FactoryGirl.create(:user, user_points: 0)
    photo_game.missions << mission
    sign_in_as user
    get "/api/v1/missions/#{mission.id}/games.json"
    json = ActiveSupport::JSON.decode(response.body)

    game = json['games'].last
    game['title'].should be_present
    game['id'].should be_present

    game_id = game['id']
    game_id.should == photo_game.id
    get "/api/v1/games/#{game_id}.json"
    json = ActiveSupport::JSON.decode(response.body)
    json['game']['id'].should == game_id

    get "/api/v1/games/#{game_id}/tasks.json"
    json = ActiveSupport::JSON.decode(response.body)
    json['tasks'].size.should >= 1
    json['tasks'].first['title'].should be_present
    task_id = json['tasks'].first['id']

    expect {
      post "/api/v1/games/#{game_id}/buy.json"
    }.to change{user.reload.user_games.count}.by(1)
    json = ActiveSupport::JSON.decode(response.body)

    user_game = user.user_games.first
    user_task = user.user_tasks.find_by_task_id task_id
    user_task.state.should == "open"

    get "/api/v1/my/games.json"
    json = ActiveSupport::JSON.decode(response.body)
    json['games'].size.should == 1

    game = json['games'].last
    game['id'].should == game_id
    game['playing_game'].should be_present
    
    expect{
      post "/api/v1/my/tasks/#{task_id}/answer.json", answer_with: {photo: fixture_file_upload(Rails.root + 'spec/rails.png', 'image/png')}
    }.to change{user.reload.user_points}.by(user_task.task.points + photo_game.points)

    json = ActiveSupport::JSON.decode(response.body)

    user_task.reload.state.should == "completed"
    user_task.reload.verification_state.should == "verified"
    user_task.reload.approval_state.should == "active"

    user_game.reload.state.should == "completed"
    user_game.reload.finished_at.should_not be_nil    

    put "/api/v1/my/tasks/#{task_id}.json", comment: 'my personal comment to this task'
    json = ActiveSupport::JSON.decode(response.body)
    user_task.reload.comment.should_not be_nil
  end
end

feature 'task with timeout' do
  let(:game) { FactoryGirl.create(:photo_game) }
  let(:user) { FactoryGirl.create(:user) }
  let(:task) { game.tasks.last }

  before(:each) do
    task.timeout_secs = 10
    task.save
  end

  # this does not make sense...
  scenario 'the task should timeout immediatly after starting the task' do
    sign_in_as user
    post "/api/v1/games/#{game.id}/buy.json"
    user_task = user.user_tasks.where(task_id: task.id).first
    user_task.state.should == 'open'

    post "api/v1/my/tasks/#{task.id}/start.json"
    user_task.reload.state.should == 'started'

    Workers::TimedTask.perform user_task.id

    user_task.reload.should be_canceled
    user_task.state.should == 'canceled'
    user.user_games.where(game_id: game.id).first.state.should == 'cancel'
  end
end
