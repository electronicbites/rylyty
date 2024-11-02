require 'spec_helper'

describe Invitation do

  let(:user_a) { FactoryGirl.create(:user) }
  let(:user_b) { FactoryGirl.create(:user) }
  let(:user_c) { FactoryGirl.create(:user) }

  it "generates an inital ivitation for beta-users" do
    expect {
      Invitation.create email: 'test@example.com'
    }.to_not raise_error
  end

  it "a user cannot invite another user twice" do
    invitee, invited_by = user_a, user_b

    Invitation.create email: invitee.email, invited_by: invited_by

    expect {
      Invitation.create invitee: invitee, invited_by: invited_by
    }.to raise_error ActiveRecord::RecordNotUnique
  end

  it "a user cannot invite herself" do
    invitee, invited_by = user_a, user_a
    Invitation.create(invitee: invitee, invited_by: invited_by).should be_invalid
    Invitation.create(email: invitee.email, invited_by: invited_by).should be_invalid
  end

  it "a user can accept only one of multiple invitations" do
    invitee = user_a

    i1 = Invitation.create(invitee: invitee, invited_by: user_b)
    i2 = Invitation.create(invitee: invitee, invited_by: user_c)

    i1.accept!(invitee).should_not be_false
    i2.accept!(invitee).should be_false
  end

  describe "badges on accepted invitations" do
    let(:invitation_1) { FactoryGirl.create(:invitation) }
    let(:invitation_2) { FactoryGirl.create(:invitation, invited_by: invitation_1.invited_by) }
    let(:invitation_3) { FactoryGirl.create(:invitation) }
    let(:badge)        { FactoryGirl.create(:badge, title: 'Beta-Invite-Badge')}

    
    it "user should receive badge if n-th new (not-registered) user accepted invitation" do
      badge.context = "count=>2, badge_type=>beta_invite"
      badge.save
      
      expect {
        invitation_1.accept!(FactoryGirl.build(:user), true)
      }.to_not change {invitation_1.invited_by.badges}

      expect {
        invitation_2.accept!(FactoryGirl.build(:user), true)
      }.to change {invitation_2.invited_by.badges.count}.by(1)
    end
    
  end

end
