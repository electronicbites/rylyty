require 'spec_helper'

#FIXME: move to user_spec since this mostly tests methods of user

describe Friendship do
  let(:user) {FactoryGirl.create(:user)}
  let(:friend) {FactoryGirl.create(:user)}
  let(:friend_ship) {FactoryGirl.create(:friendship, friend: friend, user: user)}

  it 'should create friends in both directions' do
    friend_ship
    user.friends_by_me.should have(1).friend
    friend.friends_for_me.should have(1).user
  end

  describe '#become_friends_with' do
    it 'should create a friendship' do
      expect {
        user.become_friends_with friend
      }.to change{Friendship.count}.by(1)
    end

    it 'shouldn`t succeed if user equals friend' do
      friend_ship
      expect {
        user.become_friends_with user
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should not create an already existing friendship' do
      friend_ship
      expect {
        user.become_friends_with friend
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should not create an already existing friends_for_me' do
      friend_ship
      expect {
        friend.become_friends_with user
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should increase the friends of the user' do
      expect {
        user.become_friends_with friend
      }.to change{user.reload.friends.size}.by(1)
    end

    it 'should also increase the friends of the friend' do
      expect {
        user.become_friends_with friend
      }.to change{friend.reload.friends_for_me.size}.by(1)
    end

    it 'after becoming a friend user should be friend with' do
      user.become_friends_with friend
      user.should be_friends_with friend
    end

    it 'after becoming a friend also the friend has a new friend (because its a friend)' do
      user.become_friends_with friend
      friend.should be_friends_with user
    end
  end

  describe '#destroy_friendship_with' do
    before(:each) do
      friend_ship
    end
    it 'should destroy a friendship' do
      expect {
        user.destroy_friendship_with friend
      }.to change{Friendship.count}.by(-1)
    end
  end


  it 'should be destroyed in both directions' do
    friend_ship
    user.destroy_friendship_with friend
    user.reload.friends.should be_empty
    friend.reload.friends_for_me.should be_empty
  end

  it 'should not be friends without friendship' do
    user.friends_with?(friend).should be_false
    friend.friends_with?(user).should be_false
  end
end
