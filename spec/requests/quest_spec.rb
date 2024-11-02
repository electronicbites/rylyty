require 'spec_helper'

describe '/api/v1/quests'  do
  let(:user) { FactoryGirl.create(:user) }
  let(:quest) { FactoryGirl.create(:quest) }

  context 'when not logged in' do
    
    describe 'quest list' do
      it 'respond with 401' do
        get "/api/v1/quests"
        response.status == 401
      end
    end

    describe 'quest detail' do
      it 'respond with 401' do
        get "/api/v1/quests/123.json"
        response.status == 401
      end
    end

  end

  context 'when logged in' do

    before(:each) do
      sign_in_as user
    end

    describe 'quest list' do

      it 'respond with 200' do
        get "/api/v1/quests.json"
        response.status.should == 200
      end

      it 'responds with content_type json' do
        get "/api/v1/quests.json"
        response.content_type.should == "application/json"
      end

      it 'returns a valid json response if quests exists' do
        2.times {FactoryGirl.create(:quest)}
        get "/api/v1/quests.json"
        json = JSON.parse response.body
        json.should have_key 'quests'
        single_quest = json['quests'].first
        single_quest.should have_key 'description'
        single_quest.should have_key 'id'
      end

      it 'returns a list with 3 quests' do
        3.times {FactoryGirl.create(:quest)}
        get "/api/v1/quests.json"
        json = JSON.parse response.body
        json['quests'].count.should == 3
      end

    end

    describe 'quest detail' do

      it 'responds with 404' do
        get "/api/v1/quests/123.json"
        response.status.should == 404
      end

      it 'responds with 200' do
        get "/api/v1/quests/#{quest.id}.json"
        response.status.should == 200
      end

      it 'is valid json format' do
        get "/api/v1/quests/#{quest.id}.json"
        json = JSON.parse response.body
        json['quest'].should have_key 'description'
        json['quest'].should have_key 'id'
      end

    end
  end
end
