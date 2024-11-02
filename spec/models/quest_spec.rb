require 'spec_helper'

describe Quest do
  describe 'validation' do
    def quest opts = {}
      FactoryGirl.build :quest, opts
    end

    it 'is be valid' do
      quest.should be_valid
    end

    it 'description is required' do
      quest(description: nil).should_not be_valid
    end

  end
end