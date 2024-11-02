# encoding: utf-8
require 'spec_helper'

describe Game do


  describe 'validations' do
    def game opts = {}
      FactoryGirl.build :game, opts
    end

    it 'should be valid' do
      game.should be_valid
    end

    it 'new game with mission should be valid' do
      game(missions: [FactoryGirl.create(:mission_with_games)]).should be_valid
    end

    it 'required fields' do
      game(title: nil).should_not be_valid
      game(short_description: nil).should_not be_valid
      game(description: nil).should_not be_valid
      game(costs: nil).should_not be_valid
    end
  end

  describe '#author' do
    let(:user) {FactoryGirl.create(:user)}
    let(:game) {FactoryGirl.create(:game)}

    it 'a game can set an author' do
      game.author = user
    end

    it 'an author of a game should be persistent' do
      game.author = user
      game.save!
      game.reload.author.should == user
    end
  end

  describe "fulltext search" do

    let(:game_huckepack) { FactoryGirl.create(:huckepack_game) }
    let(:game_plant) { FactoryGirl.create(:plant_game) }
    let(:game_diver) { FactoryGirl.create(:diver_game) }

    before :each do
      game_huckepack.save
      game_diver.save
      game_plant.save
    end

    it "finds game “huckepack” and ”diver” for Freund" do
      found_games = Game.search_full_text("Freund")
      found_games.count.should == 2
      found_games.should include(game_huckepack, game_diver)
    end

    it "finds game “diver” for ”tauchen”" do
      found_games = Game.search_full_text("tauchen")
      found_games.count.should == 1
      found_games.should include(game_diver)
    end

    it "finds game ”plant” for ”Bahn”" do
      found_games = Game.search_full_text("Bahn")
      found_games.count.should == 1
      found_games.should include(game_plant)
    end

    it "finds game ”plant” for ”U-Bahn”" do
      found_games = Game.search_full_text("U-Bahn")
      found_games.count.should == 1
      found_games.should include(game_plant)
    end

    it "finds game ”plant” for ”Ubahn”" do
      pending "postgres tsearch wound find this"
      # found_games = Game.search_full_text("Ubahn")
      # found_games.count.should == 1
      # found_games.should include(game_plant)
    end

    it "finds game ”plant” for ”u-bahnhof”" do
      found_games = Game.search_full_text("u-bahnhof")
      found_games.count.should == 1
      found_games.should include(game_plant)
    end

    it "finds game ”plant” for ”Pflanze Blume" do
      found_games = Game.search_full_text("Pflanze Blume".split(/\s+/))
      found_games.count.should == 1
      found_games.should include(game_plant)
    end

  end

  describe '#categories' do
    let(:user) {FactoryGirl.create(:user)}
    let(:game) {FactoryGirl.create(:game)}

    it 'a category can be added to a game' do
      category_name = 'a_game_category'
      game.add_category(category_name)
      game.reload.categories.find{|c|c.value==category_name}.should be_true
    end
  end

  describe '#badges' do
    let(:user) {FactoryGirl.create(:user)}
    let(:badge) {FactoryGirl.create(:badge)}
    let(:game) {FactoryGirl.create(:game)}

    it 'a reward_badge can be added to a game' do
      game.reward_badge.should be_nil
      game.add_reward_badge(badge)
      game.reward_badge.should_not be_nil
    end

    it 'a reward_badge can be removed from a game' do
      game.add_reward_badge(badge)
      game.reward_badge.should_not be_nil
      game.remove_reward_badge
      game.reward_badge.should be_nil
    end

    it 'a game can only have one reward_badge' do
      game.add_reward_badge(badge)
      expect {
        game.add_reward_badge badge
      }.to raise_error
    end
  end

end
