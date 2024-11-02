require 'spec_helper'

describe UserTask do

  describe 'CREATE' do

    describe 'valid' do

      let(:user_task) { FactoryGirl.create(:user_task) }

      it 'should be in state open' do
        user_task.state?(:open).should be_true
      end

      it 'has a task object' do
        FactoryGirl.build(:user_task, task: nil).should_not be_valid
      end

      it 'has a user_game object' do
        FactoryGirl.build(:user_task, user_game: nil).should_not be_valid
      end

      it 'is connected to one user' do
        FactoryGirl.create(:user_task).user.should_not be_nil
      end

    end
  end

  describe '#create_for_task' do
    let(:photo_game) {FactoryGirl.create(:photo_game)}
    let(:user_game) {FactoryGirl.create(:user_game, game: photo_game)}
    let(:task) {photo_game.tasks.first}

    it 'should create a PhotoAnswer' do
      UserTask.create_for_task(task, user_game: user_game).class.should == PhotoAnswer
    end


    it 'should set user' do
      UserTask.create_for_task(task, user_game: user_game).user_id.should == user_game.user_id
    end
  end

  describe 'start a task' do

    before do
      ResqueSpec.reset!
    end
    
    it 'starts with timeout' do
      task = FactoryGirl.create(:question_task, timeout_secs: 10)
      user_task = FactoryGirl.create(:user_task, task: task)
      user_task.start!
      Workers::TimedTask.should have_scheduled(user_task.id).at(user_task.times_out_at)
    end

    it 'creates an entry in the feed_item table' do
      task = FactoryGirl.create(:question_task)
      user = FactoryGirl.create(:user)
      friend = FactoryGirl.create(:user)
      FactoryGirl.create(:friendship, friend: friend, user: user)

      user_task = FactoryGirl.create(:user_task, task: task, user: user)
      user_task.start! if user_task.timed_task?

    end
  end

  describe 'complete' do
    let(:user_task) { FactoryGirl.create(:user_task) }
    it 'automatically verify the task' do
      user_task.start!
      user_task.complete!
      user_task.verification_verified?.should == true
    end
    
    it 'add task-(mission)points to users points' do
      user = user_task
      user_task.start! 
      user = flexmock(user_task)
      user.should_receive(:collect_points).with(user_task.task.points)
      user_task.complete!
    end
  end

  describe 'cancel' do
    let(:user_task) { FactoryGirl.create(:user_task) }
    
    it 'state is canceled after event' do
      user_task.fire_events! :cancel
      user_task.canceled?.should == true
    end

    it 'can not be canceled when completed' do
      user_task.start!
      user_task.complete!
      user_task.can_cancel?.should == false
    end
  end

  describe 'timeout' do
    let(:to_task) { FactoryGirl.create(:photo_task, timeout_secs: 60) }
    let(:user_task) { FactoryGirl.create(:user_task, task: to_task) }
    
    it 'timeout by resque-scheduler' do
      user_task.started_at.should_not be_present
      user_task.start!
      Workers::TimedTask.should have_scheduled(user_task.id).at(user_task.times_out_at)
      user_task.started_at.should be_present
      user_task.finished_at.should_not be_present
      
      Workers::TimedTask.perform user_task.id
      user_task.reload.finished_at.should be_present
      user_task.canceled?.should == true
      Workers::TimedTask.should_not have_scheduled(user_task.id).at(user_task.times_out_at)
    end
  end

  it 'can have an additional text comment' do
    user_task = FactoryGirl.build(:user_task)
    user_task.comment = 'FooFooFoo'
    user_task.save
    user_task.reload.comment.should == 'FooFooFoo'
  end

end


