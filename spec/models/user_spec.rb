require 'spec_helper'

describe User do

  def u opts = {}
    FactoryGirl.build :user, opts
  end

  describe 'validations' do

    subject { u }
    it { should be_valid }

    it 'validates #email' do
      u(email: nil).should                      be_invalid
      u(email: '').should                       be_invalid
      u(email: 'abc').should                    be_invalid
      u(email: 'foo@googlemail.com').should     be_valid
      u(email: 'foo@geddupp.de').should be_valid
    end

    it 'validates #username' do
      u(username: nil).should                   be_invalid
      u(username: 'fooo').should                be_valid
    end

    it '#username should be unique' do
      FactoryGirl.create(:user, username: '123123123')
      u(username: '123123123').should be_invalid
    end

    it '#facebook_id should be unique' do
      FactoryGirl.create(:user, facebook_id: '123123123')
      User.find_by_facebook_id('123123123').should be_present
      u(facebook_id: '123123123').should be_invalid
    end

    it '#facebook_id should not be required' do
      u(facebook_id: nil).should be_valid
    end
  end

  describe '#buys_game' do
    let(:game) {FactoryGirl.create(:game, costs: 23)}
    let(:photo_game) {FactoryGirl.create(:photo_game, costs: 23)}
    let(:user) {FactoryGirl.create(:user)}
    let(:poor_user) {FactoryGirl.create(:user, credits: 22)}

    it 'the game should be add to games of user' do
      user.buy_game! game
      user.games.should include game
    end

    it 'the games tasks should be added to existing user_tasks of user ' do
      user.buy_game! game
      expect {
        user.buy_game! photo_game
      }.to change {user.user_tasks.collect{|user_task|user_task.task}}.by(photo_game.tasks)
    end

    it 'the cost of the game should be withdrawn of the users credits' do
      expect {
        user.buy_game! game
      }.to change{user.credits}.by(-23)
    end

    it 'if user has not enough credits buy_game should return false' do
      poor_user.buy_game!(game).should be_false
    end

    it 'if user has not enough credits no game should be added to users games' do
      poor_user.buy_game!(game)
      poor_user.reload.games.should_not include game
    end

    it 'buygame should return the new usergame in case of success' do
      user.buy_game!(game).should be_an_instance_of(UserGame)
    end

    it 'if user has not enough credits nothing should be withdrawn' do
      expect {
        poor_user.buy_game! game
      }.to_not change{poor_user.reload.credits}
    end

    it 'should create a user_game object' do
      expect {
        user.buy_game! game
      }.to change{UserGame.count}.by(1)
    end

    it 'should create user_task objects for every task in the game' do
      game.tasks.size.should > 0
      expect {
        user.buy_game! game
      }.to change{UserTask.count}.by(game.tasks.size)
    end

    it 'photo-answers should have an attribute photo' do
      task = photo_game.tasks.first
      task.should be_an_instance_of(PhotoTask)
      user.user_games.should be_empty

      user.buy_game! photo_game

      user_task = user.reload.user_games.where(game_id: photo_game.id).first\
                    .user_tasks.where(task_id: task.id).first
      user_task.should be_an_instance_of(PhotoAnswer)
      user_task.should be_respond_to(:photo)
    end

    it "task are sortable" do
      original = game.tasks.map(&:id)
      target = [original[0], original[2], original[1]]

      expect {
        game.tasks[2].insert_at(2) # move 3rd item at position 2
      }.to change { game.reload.tasks.map(&:id) }.from(original).to(target)

    end

    it "games ordered tasks reflect in user_games" do
      # moving things around a bit to make this a bit more exiting ;)
      game.tasks.first.move_to_bottom
      game.reload

      user.buy_game! game
      user.reload

      game.tasks.map(&:id).should =~ user.user_tasks.map(&:task_id)
    end

    context "user without credits" do
      let(:user) {FactoryGirl.create(:user_missing_credits)}

      it "should not raise an error" do
        expect {
          user.buy_game! game
        }.to_not raise_error
      end

      it "user will not have bought the game" do
        expect {
          user.buy_game! game
        }.to_not change(user, :games)
      end
    end
  end


  describe '#can_play' do
    let(:game) {FactoryGirl.create(:game)}
    let(:expensive_game) {FactoryGirl.create(:game, costs: 666)}
    let(:game_15) {FactoryGirl.create(:game, minimum_age: 15)}
    let(:game_18) {FactoryGirl.create(:game, minimum_age: 18)}
    let(:game_min_required) {FactoryGirl.create(:game, min_points_required: 423)}
    let(:fifteen_year_old) {FactoryGirl.create(:fifteen_year_old)}
    let(:almost_fifteen_year_old) {FactoryGirl.create(:almost_fifteen_year_old)}
    let(:newbie) {FactoryGirl.create(:user, user_points: 0)}
    let(:pro) {FactoryGirl.create(:user, user_points: 2000)}
    let(:badge) {FactoryGirl.create(:badge)}
    let(:restriction_badge) {FactoryGirl.create(:badge)}

    it 'a user cannot play a game when he has not enough credits' do
      fifteen_year_old.can_play(expensive_game).should be_false
    end

    it 'a user can play all games without any restrictions' do
      fifteen_year_old.can_play(game).should be_true
    end

    it 'a user can play games with age restrictions and correct age' do
      fifteen_year_old.can_play(game_15).should be_true
    end

    it 'a user can not play games with age restrictions and incorrect age (off by one)' do
      almost_fifteen_year_old.can_play(game_15).should be_false
    end

    it 'a user can not play games with age restrictions and incorrect age' do
      fifteen_year_old.can_play(game_18).should be_false
    end

    it 'a user can not play games without having required badges' do
      game.add_restriction_badge(restriction_badge)
      pro.can_play(game).should be_false
    end

    it 'if game has no min_requirenments a user can play the game, even if he has no points' do
      newbie.can_play(game).should be_true
    end

    it 'if a game has min_requirenments and user has enough points a user can play this game' do
      newbie.can_play(game_min_required).should be_false
    end

    it 'if a game has min_requirenments and user has not enough points a user cannot play this game' do
      pro.can_play(game_min_required).should be_true
    end
  end

  describe 'can_buy' do
    let(:user_with_credits) {FactoryGirl.create(:user, credits: 200)}
    let(:user_with_no_credits) {FactoryGirl.create(:user_no_credits)}
    let(:user_credits_but_young) {FactoryGirl.create(:almost_fifteen_year_old)}
    let(:user_no_credits_and_young) {FactoryGirl.create(:almost_fifteen_year_old, credits: 0)}
    let(:game_14) {FactoryGirl.create(:game, minimum_age: 14)}
    let(:game_18) {FactoryGirl.create(:game, minimum_age: 18)}
    
    it 'a user can buy a game if he has enough credits' do
      user_with_credits.can_buy(game_14).should be_true
    end

    it 'a user cannot buy the game if he has not enough credits' do
      user_with_no_credits.can_play(game_14).should be_false
    end

    it 'a user can buy a game if he is old enough' do
      user_with_credits.can_buy(game_18).should be_true
    end

    it 'a young user with credits can buy game with no age limit' do
      user_credits_but_young.can_buy(game_14).should be_true
    end

    it 'a young user with no credits cannot buy game with no age limit' do
      user_no_credits_and_young.can_buy(game_14).should be_false
    end

    it 'a 14 year old user cannot buy the game if its limited by age' do
      user_credits_but_young.can_buy(game_18).should be_false
    end

  end

  describe '#age' do
    it 'a user without a birthday should be under 16' do
      FactoryGirl.build(:user, birthday: nil).age.should < 16
    end
  end

  describe '#user_badges' do
    let(:user) {FactoryGirl.create(:user)}
    let(:badge_1) {FactoryGirl.create(:badge)}
    let(:game) {FactoryGirl.create(:game)}
    let(:badge_2) {FactoryGirl.create(:badge)}
    # let(:game_2) {FactoryGirl.create(:game, reward_badge: badge_2)}

    it 'a user can earn a badge' do
      game.add_reward_badge(badge_1)
      expect {
        user.earn_user_badge(badge_1)
      }.to change{user.badges.size}.by(1)
    end

    it 'a user can query whether he has earned a badge' do
      earned_badge = user.user_badges.first
      if earned_badge.nil?
        user.earn_user_badge(badge_2)
        earned_badge = badge_2
      end

      user.has_user_badge(earned_badge).should be_true
    end
  end

  describe "playing a game with an optional task" do
    let(:user) { FactoryGirl.create(:user) }
    let(:game) do
      FactoryGirl.create(:game,
        tasks: [FactoryGirl.create(:question_task, points: 1),
                FactoryGirl.create(:question_task, points: 1, optional: true),
                FactoryGirl.create(:question_task, points: 1)]
      )
    end

    before :each do
      user.buy_game! game
    end

    it "the user only earns the points of the completed tasks" do
      user_game = user.user_games.find_by_game_id(game.id)
      expect {
        user_game.user_tasks[0].answer_with(answer: 'foo')
        user_game.user_tasks[1].answer_with(answer: 'foo')
      }.to change {user.reload.user_points}.by(2)
    end
  end

  describe "playing a completed game with an open, optional task" do

    let(:user) { FactoryGirl.create(:user) }
    let(:game) do
      FactoryGirl.create(:game,
        tasks: [FactoryGirl.create(:question_task, points: 1),
                FactoryGirl.create(:question_task, points: 1, optional: true),
                FactoryGirl.create(:question_task, points: 1)]
      )
    end

    before(:each) do
      user.buy_game! game
      user_game = user.user_games.find_by_game_id(game.id)
      user_game.user_tasks[0].answer_with(answer: 'foo')
      user_game.user_tasks[2].answer_with(answer: 'foo')
      user_game.reload.completed?.should be_true
    end

    it "the user earns points when compleating the optional task" do
      user_game = user.user_games.find_by_game_id(game.id)
      expect {
        user_game.user_tasks[1].answer_with(answer: 'foo')
      }.to change {user.reload.user_points}.by(1)
    end
  end

end
