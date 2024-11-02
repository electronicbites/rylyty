require 'spec_helper'

describe Mission do

  describe 'validations' do
    def mission opts = {}
      FactoryGirl.build :mission, opts
    end

    it 'required fields' do
      mission.should be_valid
      mission(games: []).should be_valid
      mission(games: [FactoryGirl.create(:game)]).should be_valid
    end
  end

  describe '#do_mission' do
    let(:user) {FactoryGirl.create(:user)}
    let(:game) {FactoryGirl.create(:game)}


    it 'should as soon a user started a mission he collects mission points' do
      mission_for_points = FactoryGirl.create(:mission, games: [game])
      user_mission = user.start_mission(mission_for_points)
      user_mission.points.should >= 1
    end

    it 'should not start a mission more than once' do
      mission_for_once = FactoryGirl.create(:mission, games: [game])
      before_size = user.user_missions.size
      2.times {user.start_mission(mission_for_once).mission.id.should eql(mission_for_once.id)}
      user.user_missions.size.should eql(before_size + 1)
    end
  end

end
