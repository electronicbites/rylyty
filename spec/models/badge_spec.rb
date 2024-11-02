require 'spec_helper'

describe Badge do

  describe 'validations' do
    def badge opts = {}
      FactoryGirl.build :badge, opts
    end

    it 'required fields' do
      badge(title: nil).should_not be_valid
      badge(title: 'any title').should be_valid
    end
  end
  
  describe 'badge associations' do
    it 'a badge can be the reward of n games' do
      game_1 = FactoryGirl.create(:game)
      game_2 = FactoryGirl.create(:game)
      badge = FactoryGirl.create(:badge)

      game_1.add_reward_badge badge
      game_2.add_reward_badge badge
      
      badge.games(badge.id, 'reward_badge_id').include?(game_1).should be_true
      badge.games(badge.id, 'reward_badge_id').include?(game_2).should be_true
    end
    
    it 'all games which provide a certain badge can be shown at once' do
      badge_1 = FactoryGirl.create(:badge)
      badge_2 = FactoryGirl.create(:badge)
      game_1 = FactoryGirl.create(:game)
      game_2 = FactoryGirl.create(:game)
      game_3 = FactoryGirl.create(:game)

      game_1.add_reward_badge badge_1
      game_3.add_reward_badge badge_1
      game_2.add_reward_badge badge_2
      
      
      badge_1.games(badge_1.id, 'reward_badge_id').include?(game_1).should be_true
      badge_1.games(badge_1.id, 'reward_badge_id').include?(game_2).should be_false
      badge_1.games(badge_1.id, 'reward_badge_id').include?(game_3).should be_true
      
      badge_2.games(badge_2.id, 'reward_badge_id').include?(game_1).should be_false
      badge_2.games(badge_2.id, 'reward_badge_id').include?(game_2).should be_true
      badge_2.games(badge_2.id, 'reward_badge_id').include?(game_3).should be_false
    end
  end
  
  describe 'earning badges' do
    it 'a badge can be earned by a user only once' do
      user = FactoryGirl.create(:user)
      game = FactoryGirl.create(:game)
      badge = FactoryGirl.create(:badge)
      
      user.earn_user_badge badge
      # next user_badge_event with same badge for same user should not be possible
      lambda { user.earn_user_badge badge }.should raise_error
    end
  end
  
end
