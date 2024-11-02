require 'spec_helper'

describe BetaUser do
    it 'should  not send a confirmation mail automaticly' do
      expect {
        beta_user = FactoryGirl.create(:beta_user)
      }.to_not change(ActionMailer::Base.deliveries, :size)
    end

    it 'should create a not confirmed betauser' do
      beta_user = FactoryGirl.create(:beta_user_not_confirmed)
      beta_user.should_not be_confirmed
    end

    it 'confirm should switch a betauser to confirmed' do
      beta_user = FactoryGirl.create(:beta_user_not_confirmed)
      beta_user.confirm!
      beta_user.reload.should be_confirmed
    end

    it 'should create a confirmed betauser' do
      beta_user = FactoryGirl.create(:beta_user)
      beta_user.should be_confirmed
    end
end