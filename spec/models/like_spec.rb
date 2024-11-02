require 'spec_helper'

describe Like do

  describe 'validations' do
    def like opts = {}
      FactoryGirl.build :like, opts
    end

    it 'required fields' do
      like.should be_valid
    end

    it 'should require user' do
      like(user: nil).should_not be_valid
    end

    it 'should require user_task' do
      like(user_task: nil).should_not be_valid
    end

    it 'should require completed user_task' do
      like(user_task: FactoryGirl.create(:user_task_started)).should_not be_valid
    end
  end

end
