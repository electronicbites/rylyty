require 'spec_helper'

describe UserGame do

  let(:user_game) { FactoryGirl.create(:user_game) }

  it "should be in state 'active' when created" do
    user_game.state?(:active).should be_true
  end

  it "should be purchasable only once per user" do
    expect {
      user_game.user.buy_game!(user_game.game)
    }.to raise_error(ActiveRecord::RecordInvalid)
  end

  describe "with 3 open tasks" do
    let(:user_game_with_3_open_tasks) { FactoryGirl.create(:user_game_with_3_open_tasks) }

    it "should have an open user_task" do
      user_game_with_3_open_tasks.open_tasks?.should be_true
    end

    it "should have 3 open user_tasks" do
      user_game_with_3_open_tasks.open_tasks.count.should == 3
    end

    it "should have only open user_tasks" do
      user_game_with_3_open_tasks.open_tasks.all? { |t|
        t.state?(:open)
      }.should be_true
    end

    it "should not transition into 'completed' state" do
      user_game_with_3_open_tasks.complete.should be_false
    end

    it "visibility is set to COMMUNITY if user is older than 16 years" do
      user_game.user.age.should >= 16
      user_game.feed_visibility.should == UserGame::Visibility::COMMUNITY
    end

    it "visibility is set to FRIENDS if user is less than 16 years old" do
      user_game = FactoryGirl.create(:user_game_young_user)
      user_game.user.age.should < 16
      user_game.feed_visibility.should == UserGame::Visibility::FRIENDS
    end

  end

  describe "with 3 tasks, all completed" do
    let(:user_game_with_3_open_tasks) { FactoryGirl.create(:user_game_with_3_open_tasks) }

    it "should not have any open tasks" do
      user_game_with_3_open_tasks.user_tasks.each {|t|
        t.start!
        t.complete!
      }
      user_game_with_3_open_tasks.open_tasks?.should be_false
    end

    # this cannot be tested here / in this way :(
    # it "should have transitioned into 'completed' state" do
    #   user_game_with_3_open_tasks.user_tasks.each {|t|
    #     t.start!
    #     t.complete!
    #   }
    #   puts user_game_with_3_open_tasks.inspect
    #   puts user_game_with_3_open_tasks.user_tasks.inspect
    #   user_game_with_3_open_tasks.completed?.should be_true
    # end

  end

  describe "badges on completion" do
    let(:game) { FactoryGirl.create(:game) }
    let(:user) {FactoryGirl.create(:user)}
    let(:category) { FactoryGirl.create(:tag, id: BadgeFinder::CATEGORIES.first, context: Tag::GAME_CATEGORY_TYPE) }
    let(:category_2) { FactoryGirl.create(:tag, id: BadgeFinder::CATEGORIES.last, context: Tag::GAME_CATEGORY_TYPE) }
    let(:badge) {FactoryGirl.create(:badge, title: 'the super badge')}
    let(:badge_2) {FactoryGirl.create(:badge, title: 'the super badge 2')}

    before(:all) do
      game.add_reward_badge(badge)
    end

    it "user should receive reward badge on completion" do
      user_game_with_reward_badge = FactoryGirl.create(:user_game, game_id: game.id)
      expect {
        user_game_with_reward_badge.complete!
      }.to change {user_game_with_reward_badge.user.user_badges.count}.by(1)
    end

    it "user should receive category badge on completion of specific number of special games as defined in CategoryBadgeModel" do
      badge.context = "count=>2, badge_type=>game_completed, game_category_id=>#{category.id}"
      badge.save

      badge_2.context = "count=>1, badge_type=>game_completed, game_category_id=>#{category_2.id}"
      badge_2.save

      user_game_1 = FactoryGirl.create(:user_game, user: user)
      user_game_2 = FactoryGirl.create(:user_game, user: user_game_1.user)
      
      # ensure games have test-category
      user_game_1.game.categories << category unless user_game_1.game.categories.include? category
      user_game_2.game.categories << category unless user_game_2.game.categories.include? category
      user_game_2.game.categories << category_2 unless user_game_2.game.categories.include? category_2

      expect {
        user_game_1.complete!
      }.to_not change {user_game_1.user.badges}

      expect {
        user_game_2.complete!
      }.to change {user_game_2.user.badges.count}.by(2)

    end
  end

  describe "with an optional task" do

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
    end

    it "the game changes state to completed when all tasks but the optional where answered" do
      user_game = user.user_games.find_by_game_id(game.id)
      expect {
        user_game.user_tasks[0].answer_with(answer: 'foo')
        user_game.user_tasks[2].answer_with(answer: 'foo')
      }.to change { user_game.reload.completed? }.from(false).to(true)
    end

    it "the game is still playable when there is an open (optional) task" do
      user_game = user.user_games.find_by_game_id(game.id)
      user_game.user_tasks[0].answer_with(answer: 'foo')
      user_game.user_tasks[2].answer_with(answer: 'foo')

      expect {
        user_game.user_tasks[1].answer_with(answer: 'optional foo')
      }.to change { user_game.reload.all_tasks_completed?(true) }.from(false).to(true)
    end

  end

end
