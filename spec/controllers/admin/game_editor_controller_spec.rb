require 'spec_helper'

I18n.locale = 'de'

describe Cockpit::GameEditorsController do
  render_views

  # game_editor is called via cockpit-routes from active_admin
  describe 'edit game' do
    let(:game) {FactoryGirl.create(:game)}
    let(:admin_user) {FactoryGirl.create(:admin_user)}
    let(:reward) {FactoryGirl.create(:badge)}
    let(:restriction) {FactoryGirl.create(:badge)}

    before(:each) do
      sign_in admin_user
    end

    it 'should display game' do
      get :edit, id: game.id
      response.body.should include game.title
    end

    it 'should create game' do
      new_game_attributes = FactoryGirl.attributes_for(:game)
      new_game_attributes['reward_badge_id'] = reward.id
      new_game_attributes['restriction_badge_id'] = restriction.id
      new_game_attributes.delete(:tasks)
      expect {
        post :create, game: new_game_attributes
      }.to change(Game, :count).by(1)
      response.should redirect_to edit_cockpit_game_editor_url(id: assigns(:game).id)
    end

    it 'should edit game' do
      new_game_attributes = FactoryGirl.attributes_for(:game)
      new_game_attributes['reward_badge_id'] = reward.id
      new_game_attributes['restriction_badge_id'] = restriction.id
      
      new_game_attributes.delete(:tasks)
      new_game_attributes[:id] = game.id

      expect {
        put :update, id: game.id, game: new_game_attributes
      }.to change(Game, :count).by(0)

      new_game_attributes['title'] = "#{game.title}_changed"
      expect {
        put :update, id: game.id, game: new_game_attributes
      }.to change {game.reload.title}

      response.should redirect_to edit_cockpit_game_editor_url(id: assigns(:game).id)
    end
  end

  # game_editor is called via cockpit-routes from active_admin
  describe 'edit task' do
    let(:game) {FactoryGirl.create(:photo_game)}
    let(:game_without_tasks) {FactoryGirl.create(:game, tasks: [])}
    let(:admin_user) {FactoryGirl.create(:admin_user)}
    let(:photo_game) {FactoryGirl.create(:photo_game)}

    before(:each) do
      sign_in admin_user
    end

    it 'should display task' do
      get :edit, id: game.id, task_id: game.tasks.first.id, tasks: 'true'
      response.body.should include game.tasks.first.title
    end

    it 'should create task' do
      new_task_attributes = FactoryGirl.attributes_for(:photo_task)
      new_task_attributes[:icon] = fixture_file_upload(Rails.root.join('spec', 'rails.png'), 'image/png')
      expect {
        post :update, id: game_without_tasks.id, tasks: 'true', task: new_task_attributes, task_type: 'photo_task'
      }.to change(Task, :count).by(1)
      response.should redirect_to edit_cockpit_game_editor_url(id: assigns(:task).game.id, task_id: assigns(:task).id, tasks: true)

      assigns(:task).icon.url.should be_present
      assigns(:task).icon.url.match(/\/assets\/icons\/photo_tasks\/#{assigns(:task).id}\//).present?.should be_true
    end

    it 'should edit task' do
      photo_task = photo_game.tasks.first

      new_task_attributes = FactoryGirl.attributes_for(:photo_task)
      new_task_attributes[:id] = photo_task.id

      expect {
        put :update, id: photo_task.game.id, tasks: 'true', task_id: photo_task.id, photo_task: new_task_attributes, task_type: 'photo_task'
      }.to change(Task, :count).by(0)

      new_task_attributes['title'] = "#{photo_task.title}_changed"
      expect {
        put :update, id: photo_task.game.id, tasks: 'true', task_id: photo_task.id, photo_task: new_task_attributes, task_type: 'photo_task'
      }.to change {photo_task.reload.title}

      response.should redirect_to edit_cockpit_game_editor_url(id: photo_task.game.id, task_id: photo_task.id, tasks: true)
    end
  end

end
