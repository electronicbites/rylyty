require 'spec_helper'

describe PushNotifier do
  it "should send APNs to user" do
    user = FactoryGirl.create(:user_with_apn)
    flexmock(APN).should_receive(:notify).with(user.device_token, FlexMock.any).once
    PushNotifier.new.send_notification_to_user_limited(user, "foo")
  end
  
  it "should not send a notification without a device token" do
    user = FactoryGirl.create(:user_with_apn, device_token: nil)
    flexmock(APN).should_receive(:notify).times(0)
    PushNotifier.new.send_notification_to_user_limited(user, "foo")
  end
  
  it "should not a notification only once in 12 hours" do
    user = FactoryGirl.create(:user_with_apn, last_apn_send_date: Time.now - 11.hours)
    flexmock(APN).should_receive(:notify).with(user.device_token, FlexMock.any).times(0)
    PushNotifier.new.send_notification_to_user_limited(user, "foo")
  end
end