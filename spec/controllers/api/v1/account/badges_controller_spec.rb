require 'spec_helper'

describe Api::V1::Account::BadgesController do
  render_views

  describe 'index' do
    let(:user) {FactoryGirl.create(:user)}
    let(:badge) {FactoryGirl.create(:badge)}
    let(:game) {FactoryGirl.create(:game)}

    before(:each) do
      sign_in :user, user
    end

    it 'should be successfull' do
      get :index, format: :json
      response.status.should == 200
    end

    it 'should return badge title' do
      game.add_reward_badge badge
      user.earn_user_badge badge
      user.reload

      get :index, format: :json
      parse_json['badges'].first['title'].should == badge.title
    end

  end
end
