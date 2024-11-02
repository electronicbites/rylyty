class PushNotifier

  def send_notification_to_user_limited(user, message)
    if (user.last_apn_send_date.nil? || Time.now - 12.hours > user.last_apn_send_date)
      send_notification_to_user(user, message)
      user.last_apn_send_date = Time.now
      user.save
    end
  end

  def send_notification_to_user(user, message)
    if !user.device_token.nil?
      opts_hash = {alert: message, environment: Rails.env, verbose: true}
      APN.notify(user.device_token, opts_hash)      
    end
  end
end