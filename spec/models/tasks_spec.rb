require 'spec_helper'

describe Tasks do
  
  describe '#validation' do
    def task opts = {}
      FactoryGirl.build :task, opts
    end

    it 'should be valid' do
      task.should be_valid
    end

    it 'title should be required' do
      task(title: nil).should_not be_valid
    end

    it 'type should be required' do
      task(type: nil).should_not be_valid
    end
  end

end
