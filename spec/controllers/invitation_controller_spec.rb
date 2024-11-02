require 'spec_helper'

describe InvitationController do
  render_views

  describe "open invitation form" do
    let (:invitation)    {FactoryGirl.create(:invitation)}
    let (:token)         {invitation.token}
    let (:invitee_email) {invitation.email}

    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]
    end

    it "copy token into cookie" do
      get :new, token: token
      token.should == response.cookies['invitation_token']
    end

    it "includes the invitees email" do
      get :new, token: token
      response.body.should include "value=\"#{invitee_email}\""
    end
  end

  describe "POST user registration" do
    let (:invitation)    {FactoryGirl.create(:invitation)}
    let (:token)         {invitation.token}
    let (:invitee_email) {invitation.email}

    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]

      @user_data = {
        email: invitee_email,
        username: 'fancy_user_name',
        password: "foo-passw0rd",
        password_confirmation: "foo-passw0rd",
        tos: "true"
      }
    end

    it "renders register form" do
      pending "Test if the form contains all Forms and the correct value for accepting the TOS"
      get :new, token: token
    end

    it "creates a user" do
      expect {
        cookies['invitation_token'] = token
        post :create, user: @user_data
      }.to change(User, :count)

      response.code.should == "302"
      response.should redirect_to(completed_user_registration_path)
    end

    it "ivitation got linked with a user" do
      expect {
        cookies['invitation_token'] = token
        post :create, user: @user_data
      }.to change { invitation.reload.invitee }.from(nil)
    end

    it "ivitation got linked with a download_link" do
      expect {
        cookies['invitation_token'] = token
        post :create, user: @user_data
      }.to change { invitation.reload.download_link }.from(nil)
    end

    it "wont create a user twice" do
      invitation.accept!(FactoryGirl.create(:user, email: invitee_email)).should be_true
      expect {
        cookies['invitation_token'] = token
        post :create, user: @user_data
      }.to_not change(User, :count)

      response.code.should == "302"
      response.should redirect_to(completed_user_registration_path)
    end

    it "creates a feed_entry" do
       expect {
        cookies['invitation_token'] = token
        post :create, user: @user_data
      }.to change(User, :count)

      response.code.should == "302"
      response.should redirect_to(completed_user_registration_path)
      
      feed_item = FeedItem.where(event_type: Invitation::EventTypes::INVITE_ACCEPTED).first
      feed_item.should_not be_nil
    end

    it "invitee becomes friend with invitation sender" do
      invited_by = invitation.invited_by
      expect {
        cookies['invitation_token'] = token
        post :create, user: @user_data
      }.to change(User, :count)

      response.code.should == "302"
      response.should redirect_to(completed_user_registration_path)

      user = User.where(email: @user_data[:email]).first
      user.friends_with?(invited_by).should be_true   
    end
  end
end
