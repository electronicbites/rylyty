require 'spec_helper'

describe Api::V1::Account::GamesController do

  describe 'index' do
    let(:user) {FactoryGirl.create(:user)}
    let(:user_game1) {FactoryGirl.create(:user_game_with_3_tasks_1_started_1_open, user: user )}
    let(:user_game2) {FactoryGirl.create(:user_game_with_3_open_tasks, user: user )}
    let(:game3) {FactoryGirl.create(:photo_game )}

    before(:each) do
      [game3, user_game1, user_game2]
      sign_in :user, user
    end

    it 'should include bought games' do
      get 'index', format: 'json'
      assigns(:user_games).should include(user_game1, user_game2)
    end

    it 'should not include a not bought game' do
      get 'index', format: 'json'
      assigns(:user_games).should_not include game3
    end

    context "json" do
      render_views
      it 'should return a collection of games' do
        get 'index', format: 'json'
        json = ActiveSupport::JSON.decode(response.body)
        json.should have_key 'games'
        json['games'].size.should == 2
      end

      it 'should include user information' do
        get 'index', format: 'json'
        parse_json['games'].first.should have_key 'playing_game'
      end
    end
  end

  describe 'list user_game with all task types' do
    render_views
    let(:game) {
      FactoryGirl.create(:game, tasks: [
        FactoryGirl.create(:photo_task), FactoryGirl.create(:multiple_choice_task), FactoryGirl.create(:question_task)
      ])
    }
    let(:user) { FactoryGirl.create(:user) }

    before(:each) do
      sign_in :user, user
      user.buy_game! game
      user.user_games.first.user_tasks.map{|t| t.class.to_s}.should == ['PhotoAnswer', 'MultipleChoiceAnswer', 'TextAnswer']
    end

    it "should find all view templates" do
      expect {
        get 'index', format: 'json'
      }.to_not raise_error(ActionView::TemplateError)
    end
  end

  describe 'show' do
    render_views
    let(:user_game) {FactoryGirl.create(:user_game_with_3_tasks_1_started_1_open)}
    let(:user) {user_game.user}
    let(:game) {user_game.game}

    before(:each) do
      sign_in :user, user
      user.user_games.should include user_game
    end

    it 'should include the state of the game' do
      get 'show', id: game.id, format: 'json'
      parse_json['game']['playing_game'].should have_key 'state'
    end

    it 'should include finished_at attribute_of the game' do
      get 'show', id: game.id, format: 'json'
      parse_json['game']['playing_game'].should have_key 'finished_at'
    end

    it 'should include a list of tasks' do
      get 'show', id: game.id, format: 'json'
      parse_json['game'].should have_key 'tasks'
    end

    it 'a task of the game should include the playing_task' do
      get 'show', id: game.id, format: 'json'
      parse_json['game']['tasks'].first.should have_key 'playing_task'
    end
  end

  describe 'update_privacy' do
    let(:user_game) {FactoryGirl.create(:user_game_with_3_open_tasks)}
    let(:user) {user_game.user}

    before(:each) do
      sign_in :user, user
      user.user_games.should include user_game
    end

    it 'after save feed_visibility setting has changed from community to friends' do
      user_game.feed_visibility.should == UserGame::Visibility::COMMUNITY
      put :update_privacy, {
        game_id: user_game.game_id,
        feed_visibility: UserGame::Visibility::FRIENDS
      }
      user_game.reload
      user_game.feed_visibility.should == UserGame::Visibility::FRIENDS
    end

    it 'feed_visibility setting did not change from community to friends because user is less tahn 15 years old' do
      user_game = FactoryGirl.create(:user_game_young_user)
      user = user_game.user
      sign_in :user, user
      
      put :update_privacy, {
        game_id: user_game.game_id,
        feed_visibility: UserGame::Visibility::COMMUNITY
      }      

      user_game.reload
      user_game.feed_visibility.should == UserGame::Visibility::FRIENDS
    end

  end
end
