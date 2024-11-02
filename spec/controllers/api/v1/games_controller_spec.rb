require 'spec_helper'

# recommended games are included in many cases - disable them with before(:each)
# to avoid unexpected response-data, or handle locally
# Game::RecommendedGames::GAME_IDS.clear

describe Api::V1::GamesController do
  let(:mission) {FactoryGirl.create(:mission_with_games)}
  let(:game_in_mission) {mission.games.first}

  context 'mission id is given' do
    let(:game_not_in_mission) {FactoryGirl.create(:game)}
    let(:quest) { FactoryGirl.create(:quest)}
    let(:game_not_in_quest) { FactoryGirl.create(:game)}

    before(:each) do
      sign_in :user, FactoryGirl.create(:user)
    end

    it 'should include games in mission' do
      get :index, mission_id: mission.id, format: :json
      assigns(:games).size.should == mission.games.size
      assigns(:games).should include game_in_mission
    end

    it 'should not include games which are not in a mission' do
      get :index, mission_id: mission.id, format: :json
      assigns(:games).should_not include game_not_in_mission
    end

    it 'should include games in quest' do
      game_in_quest = FactoryGirl.create(:game, quest: quest)
      get :index, quest_id: quest.id, format: :json
      assigns(:games).size.should == quest.games.size
      assigns(:games).should include game_in_quest
    end

    it 'should not include games wich are not in the quest' do
      get :index, quest_id: quest.id, format: :json
      assigns(:games).should_not include game_not_in_quest
    end
  end

  describe '#show' do
    render_views
    let(:user) {FactoryGirl.create(:user)}
    let(:game) {FactoryGirl.create(:game)}
    let(:game_without_icon) {FactoryGirl.create(:game, icon: nil)}
    let(:game_with_reward_points) {FactoryGirl.create(:game, points: 100)}

    before(:each) do
      sign_in :user, user
    end

    it 'should display icon_url with icon' do
      get 'show', id: game.id, format: :json
      parse_json['game'].should have_key 'icon'
    end


    it 'should also display icon_url without icon' do
      get 'show', id: game_without_icon.id, format: :json
      parse_json['game'].should have_key 'icon'
    end

    it 'should display reward-points' do
      get 'show', id: game_with_reward_points.id, format: :json
      game_json = parse_json['game']
      game_json.should have_key 'reward'
      game_json['reward']['points'].should == game_with_reward_points.total_reward_points
    end

    it 'should display reward-badge' do
      game.add_reward_badge FactoryGirl.create(:badge)    
      get 'show', id: game.id, format: :json
      game_json = parse_json['game']
      game_json.should have_key 'reward'
      game_json['reward'].should have_key 'badge'
      game_json['reward']['badge'].should have_key 'id'
      game_json['reward']['badge']['id'].should == game.reward_badge.id
    end

    it 'should add a categories node to json for games with categories' do
      %w{foo1 foo2}.each {|category| game.add_category category}
      get 'show', id: game.id, format: :json
      json = parse_json['game']
      json.should have_key 'categories'
      json['categories'].should match('foo1')
      json['categories'].should match('foo2')
    end

    it 'should not add categories node to json when there are no categories' do
      get 'show', id: game.id, format: :json
      parse_json['game'].should_not have_key 'categories'
    end

    it 'includes tasks' do
      get 'show', id: game.id, format: :json
      parse_json['game'].should have_key 'tasks'
    end
  end

  describe 'suggest' do
    render_views

    # user1 playes a game on it's own
    let(:user_game1) {FactoryGirl.create(:user_game_with_3_tasks_1_started_1_open)}
    let(:user1) {user_game1.user}
    let(:game1) {user_game1.game}

    # user2 plays a different game at it's own
    let(:user_game2) {FactoryGirl.create(:user_game_with_3_tasks_1_started_1_open)}
    let(:user2) {user_game2.user}
    let(:game2) {user_game2.game}

    # user3 playes the same game as user1
    let(:user3) { FactoryGirl.create(:user) }
    let(:user_game3) { FactoryGirl.create(:user_game_with_3_tasks_1_started_1_open, user: user3, game: game1)}

    # games, no one plays
    let(:unpurchaced_game) {FactoryGirl.create(:game, suggestion: 'd-rated')}

    # thats too expensive
    let(:unpurchaceable_game) {FactoryGirl.create(:game, costs: 1_000_000)}

    let(:game_with_suggestion) {FactoryGirl.create(:game, costs: 0, suggestion: 'this is good')}
    let(:game_without_suggestion_1) {FactoryGirl.create(:game, costs: 0, suggestion: nil)}
    let(:game_without_suggestion_2) {FactoryGirl.create(:game, costs: 0, suggestion: '')}

    before(:each) do
      # recommended games are included in many cases - disable them to avoid unexpected response-data
      Game::RecommendedGames::GAME_IDS.clear
      
      sign_in :user, user1
      user1.games.should include game1
      user1.games.should_not include game2, unpurchaced_game, unpurchaceable_game, game_with_suggestion, game_without_suggestion_1, game_without_suggestion_2
    end

    it 'suggests none of my games' do
      get 'index', suggest: true, format: :json
      assigns(:games).should_not include game1
    end

    it 'suggest all other games I can afford' do
      game2.update_attribute(:suggestion, 'this is good')
      get 'index', suggest: true, format: :json
      assigns(:games).should include game2, unpurchaced_game
    end

    it 'does not suggest a game I cannot afford' do
      get 'index', suggest: true, format: :json
      assigns(:games).should_not include unpurchaceable_game
    end

    it 'response with valid suggestions json' do
      get 'index', suggest: true, format: :json
      json = parse_json

      json.should have_key 'suggestions'
      json['suggestions'].size.should >= 1
      json['suggestions'].each do |entry|
        entry.should have_key 'suggestion'
        entry['suggestion'].should be_present
        entry.should have_key 'game'
        entry['game'].should be_present
        entry['game'].should have_key 'title'
      end
    end

    it 'does not any suggestions of games with costs >= 1 because I have no credits' do
      user1.credits = 0
      user1.save

      get 'index', suggest: true, format: :json
      assigns(:games).find{|g|g.costs>=1}.should be_nil
    end
  end

  describe '#buy' do
    render_views
    let(:user) {FactoryGirl.create(:user)}
    let(:game1) {FactoryGirl.create(:game)}
    let(:game2) {FactoryGirl.create(:game)}
    let(:user_buys_game_twice) {FactoryGirl.create(:user)}

    before(:each) do
      sign_in :user, user
    end

    it 'should return a user_game object for the bought game' do
      post 'buy', game_id: game1.id, format: :json
      assigns(:user_game).game.should == game1
    end

    it 'should return the correct user_game object also if there are more bought games' do
      user.buy_game! game2
      post 'buy', game_id: game1.id, format: :json
      assigns(:user_game).game.should == game1
    end

    it 'should return error when a user tries to buy a game more than once' do
      sign_in :user, user_buys_game_twice
      user_buys_game_twice.buy_game! game1
      post 'buy', game_id: game1.id, format: :json
      
      res_json = parse_json
      res_json['success'].should be_false
      res_json['message'].should =~ /#{I18n.t("user_games.already_bought", locale: 'de')}/
    end
  end

  describe '#index' do
    render_views

    let(:user) {FactoryGirl.create(:user)}
    let(:badge) {FactoryGirl.create(:badge)}

    before(:each) do
      sign_in :user, user
    end

    it 'should include restriction badges' do
      game_in_mission.add_restriction_badge badge
      game_in_mission.save!
      game_in_mission.reload.restriction_badge.should be_present
      game_in_mission.restriction_badge.should == badge

      get :index, mission_id: mission.id, format: :json
      json = parse_json
      json['games'].first['id'].should == game_in_mission.id
      json['games'].first.should have_key 'restriction'
      json['games'].first['restriction']['badge']['id'].should == badge.id
    end



    it 'should include created_at' do
      get :index, mission_id: mission.id, format: :json
      json = parse_json
      game = Game.find json['games'].first['id']
      json['games'].first.should have_key 'created_at'
      json['games'].first['created_at'].should == game.created_at.to_i
    end
  end

  describe '#index-recommended' do
    render_views

    let(:user) {FactoryGirl.create(:user)}
    let(:game_recommended_1) {FactoryGirl.create(:game, id: 4)}
    let(:game_recommended_2) {FactoryGirl.create(:game, id: 9)}
    let(:game_recommended_3) {FactoryGirl.create(:game, id: 2)}
    let(:game_recommended_1_with_mission) {FactoryGirl.create(:game, id: 7, missions:[FactoryGirl.create(:mission)])}
    let(:game_recommended_1_with_quest) {FactoryGirl.create(:game, id: 7)}

    before(:each) do
      sign_in :user, user
    end

    after(:each) { Game::RecommendedGames::GAME_IDS.clear }

    it 'should add recommended = true and position to recommended games, false to others' do
      pending 'not working, no idea why'
      # setup worker.map
      Game::RecommendedGames::GAME_IDS.clear.concat([game_recommended_1.id,game_recommended_2.id,game_recommended_3.id])

      game_not_recommended_1 = FactoryGirl.create(:game, id: 5)
      game_not_recommended_2 = FactoryGirl.create(:game, id: 1)

      get 'index', format: :json

      json = parse_json
      json.should have_key 'games'
      games = json['games']
      
      # it's not sure if games are sorted in backend/api or client - currently client
      test_games_order = false
      if test_games_order
        # test order of api-generated json-list
        games[0]['id'].should == game_recommended_1.id
        games[0]['recommended'].should be_true
        games[1]['id'].should == game_recommended_2.id
        games[1]['recommended'].should be_true
        games[2]['id'].should == game_recommended_3.id
        games[2]['recommended'].should be_true
        [game_not_recommended_1.id,game_not_recommended_2.id].each{|g_id|games.find{|g|g['id'].to_i==g_id}.should be_true}
      else
        # test by attributes recommended, position
        # iterate through all games and check expected attributes
        recommended_games = [game_recommended_1, game_recommended_2, game_recommended_3]
        un_recommended_games = [game_not_recommended_1, game_not_recommended_2]
        games.each do |game_hash|
          recommended_index = recommended_games.index{|g|game_hash['id']==g.id}
          if recommended_index.present?
            # this is a recommended game
            game_hash['recommended'].should be_true
            recommended_index == (game_hash['position'] - 1)
            recommended_games.delete_at(recommended_index) && recommended_games.compact!
          else
            # this is not a recommended game
            # un_recommended_games.delete(un_recommended_games.find{|g|game_hash['id']==g.id}).should be_present
          end
        end
        # all recommended/unrecommended games were removed in attribute-check
        recommended_games.should be_empty
        un_recommended_games.should be_empty
      end
    end

    it 'should only return recommended games with given mission if mission is given' do
      # setup worker.map
      Game::RecommendedGames::GAME_IDS.clear.concat([game_recommended_1.id,game_recommended_1_with_mission.id])

      get 'index', mission_id: game_recommended_1_with_mission.missions.first.id, format: :json

      json = parse_json
      json.should have_key 'games'
      
      games = json['games']
      
      recommended_games = [game_recommended_1, game_recommended_1_with_mission]
      games.each do |game_hash|
        case game_hash['id']
        when game_recommended_1.id
          true.should be_false
        when game_recommended_1_with_mission.id
          recommended_games.delete(game_recommended_1_with_mission)
        end
      end
      # all recommended listed games were removed in attribute-check
      recommended_games.should_not include(game_recommended_1_with_mission)
    end
  end

end