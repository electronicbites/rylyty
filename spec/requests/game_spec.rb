# encoding: utf-8
require 'spec_helper'

describe '/api/v1/games' do
  describe 'GET #index' do
    let(:game) { FactoryGirl.create(:game) }
    let(:user) { FactoryGirl.create(:user) }

    it 'should return a bunch of games' do
      user = FactoryGirl.create(:user)
      sign_in_as user

      Game.destroy_all
      10.times {FactoryGirl.create(:game)}
      get '/api/v1/games.json', {
        format: :json,
      }
      response.status.should == 200
      json = JSON.parse response.body
      json['games'].size.should == 10
    end

    it 'should api return 2 urls for thumb and thumb_hi' do
      image_file_path = Rails.root.join('public', 'favicon.ico')
      game.update_attribute(:image, File.new(image_file_path))
      sign_in_as user

      get "/api/v1/games/#{game.id}.json"
      json = JSON.parse response.body
      json['game']['thumb'].should match(/\/thumb\//)
      json['game']['thumb_hi'].should match(/\/thumb_hi\//)
    end

    it "show user's task for a game" do
      user_game = FactoryGirl.create(:user_game_with_3_open_tasks)
      usr = user_game.user
      sign_in_as usr

      get "/api/v1/my/games/#{user_game.game_id}.json"
      json = JSON.parse response.body
      game = json['game']
      game.should have_key 'playing_game'
      game['playing_game'].should_not have_key 'user_tasks'

      game.should have_key 'tasks'
      tasks = game['tasks']
      tasks.should have(3).things
      tasks.all? {|a_task|
        a_task.should have_key 'playing_task'
        a_task['playing_task']['user_id'].should == usr.id
        a_task['playing_task']['state'].should == 'open'
      }
    end
  end
end

describe '/api/v1/missions/1/games' do

  describe "GET games by full text query" do
    let(:user) { FactoryGirl.create(:user) }
    let(:game_huckepack) { FactoryGirl.create(:huckepack_game) }
    let(:game_plant) { FactoryGirl.create(:plant_game) }
    let(:game_diver) { FactoryGirl.create(:diver_game) }

    before :each do
      sign_in_as user
      game_huckepack.save
      game_diver.save
      game_plant.save
    end

    it "lists ”huckepack” and ”diver” game" do
      get "/api/v1/games.json?q=Freund"
      response.status.should == 200
      json = JSON.parse response.body
      json.should have_key 'games'
      json_games = json['games']
      json_games.length.should == 2
      json_games.map { |e| e['title'] }.should include(game_huckepack.title, game_diver.title)
    end

    it "accepts offset and limit parameter" do
      get "/api/v1/games.json?q=Beschreibung&limit=1&offset=1"
      response.status.should == 200
      json = JSON.parse response.body
      json.should have_key 'games'
      json_games = json['games']
      json_games.length.should == 1
      json_games.map { |e| e['title'] }.should include game_diver.title
    end
  end

  describe 'GET games by mission' do
    let(:mission) { FactoryGirl.create(:mission_with_games) }
    let(:user) { FactoryGirl.create(:user) }

    it 'should respond_with_content_type :json' do
      get "/api/v1/missions/#{mission.id}/games.json"
      response.content_type.should == "application/json"
    end

    it 'if the mission does not exist return a 404 ' do
      sign_in_as user
      get "/api/v1/missions/12345/games.json"
      response.status.should == 404
    end

    it 'valid json format' do
      sign_in_as user
      get "/api/v1/missions/#{mission.id}/games.json"
      response.status.should == 200
      json = JSON.parse response.body
      json.should have_key 'games'
      json_games = json['games']
      json_games.each {|g| g.has_key?('title').should == true}
      json_games.each {|g| g.has_key?('time_limit').should == true}
      json_games.each {|g| g.has_key?('costs').should == true}
      json_games.each {|g| g.has_key?('minimum_age').should == true}
      json_games.each {|g| g.has_key?('min_points_required').should == true}
      json_games.each {|g| g.has_key?('playable').should == true}
    end

    it 'return a list of playable games' do
      sign_in_as user
      get "/api/v1/missions/#{mission.id}/games.json"
      response.status.should == 200
      json = JSON.parse response.body
      json.should have_key 'games'
      json_games = json['games']
      json_games.length.should == 5
      json_games.each {|g| g['playable'].should equal true}
    end

    it 'return games list with no playable games ' do
      User.destroy_all
      user = FactoryGirl.create(:user_no_credits)
      sign_in_as user
      get "/api/v1/missions/#{mission.id}/games.json"
      response.status.should == 200
      json = JSON.parse response.body
      json.should have_key 'games'
      json_games = json['games']
      json_games.each {|g| g['playable'].should equal false}
    end
  end
end

describe 'post /api/v1/games/123/buy.json' do
  let(:user) { FactoryGirl.create(:user) }
  let(:game) { FactoryGirl.create(:game) }

  it 'should return status 401 if user is not logged in' do
    post "/api/v1/games/#{game.id}/buy.json"
    response.status.should == 401
  end

  it 'if user has enough credits' do
    sign_in_as user
    post "/api/v1/games/#{game.id}/buy.json"
    response.status.should == 200
    json = JSON.parse response.body
    json.has_key?('game').should be_true
  end

  it 'does not throw an exception if user has no credits' do
    sign_in_as user
    user.credits = 0
    user.save!
    expect {
      post "/api/v1/games/#{game.id}/buy.json"
    }.to_not raise_error
    
  end

  it 'game should exist in my games list' do
    pending
  end

  context "user with insufficient requirements" do
    let(:game) { FactoryGirl.create(:game, costs: 100, min_points_required: 100, minimum_age: 18) }

    let(:user_no_credits) { FactoryGirl.create(:user, credits: 10)}
    let(:user_no_points)  { FactoryGirl.create(:user, user_points: 10)}
    let(:user_under_aged) { FactoryGirl.create(:user, birthday: Date.today - 16.years)}
    let(:user_1_missing_badge) { FactoryGirl.create(:user)}

    it 'error if user has not enough credits' do
      sign_in_as user_no_credits
      post "/api/v1/games/#{game.id}/buy.json"
      response.status.should == 200
      j = parse_json
      j['success'].should be_false
      j['message'].should include I18n.t('users.errors.buying_game.insufficient_credits', need_credits: game.costs, have_credits: user.credits)
    end

    it 'error if user has not enough points' do
      sign_in_as user_no_points
      post "/api/v1/games/#{game.id}/buy.json"
      response.status.should == 200
      j = parse_json
      j['success'].should be_false
      j['message'].should include I18n.t('users.errors.buying_game.insufficient_point', need_points: game.min_points_required, have_points: user.user_points)
    end

    it 'error if user is not old enough' do
      sign_in_as user_under_aged
      post "/api/v1/games/#{game.id}/buy.json"
      response.status.should == 200
      j = parse_json
      j['success'].should be_false
      j['message'].should include I18n.t('users.errors.buying_game.insufficient_age', need_age: game.minimum_age, have_age: user.age)
    end

    it 'error if user is not old enough' do
      sign_in_as user_under_aged
      post "/api/v1/games/#{game.id}/buy.json"
      response.status.should == 200
      j = parse_json
      j['success'].should be_false
      j['message'].should include I18n.t('users.errors.buying_game.insufficient_age', need_age: game.minimum_age, have_age: user.age)
    end

    it 'error if user misses one badge' do
      badge_1 = FactoryGirl.create(:badge, title: "Irres-Badge 1")
      game_badges_restricted = FactoryGirl.create(:game, restriction_badge_id: badge_1.id)
      sign_in_as user_1_missing_badge
      post "/api/v1/games/#{game_badges_restricted.id}/buy.json"
      response.status.should == 200
      j = parse_json
      j['success'].should be_false
      j['message'].should include I18n.t('users.errors.buying_game.insufficient_badges',
        need_badges: badge_1.title,
        count: 1
      )
    end
  end
end

describe '/api/v1/quests/1/games' do
  let(:user) { FactoryGirl.create(:user) }
  let(:quest) { FactoryGirl.create(:quest) }
  let(:game) {FactoryGirl.create(:game)}

  context 'when not logged in' do
    it 'returns status 401' do
      get "/api/v1/quests/#{quest.id}/games.json"
      response.status.should == 401
    end
  end

  context 'when logged in' do
    before(:each) do
      sign_in_as user
    end

    it 'return valid json' do
      FactoryGirl.create(:game, quest: quest)
      get "/api/v1/quests/#{quest.id}/games.json"
      json = JSON.parse response.body
      json.should have_key 'games'
      single_game = json['games'].first
      single_game.should have_key 'title'
      single_game.should have_key 'short_description'
      single_game.should have_key 'id'
    end

    it 'returns a list with 3 games in the quest' do
      3.times {FactoryGirl.create(:game, quest: quest)}
      get "/api/v1/quests/#{quest.id}/games.json"
      response.status.should == 200
      json = JSON.parse response.body
      json['games'].count.should == 3
    end

    it 'should not include games not in quest' do
      3.times {FactoryGirl.create(:game, quest: quest)}
      get "/api/v1/quests/#{quest.id}/games.json"
      response.status.should == 200
      json = JSON.parse response.body
      json['games'].should_not include game
    end

  end

end