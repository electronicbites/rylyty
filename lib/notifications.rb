module Notifications

  def self.publish name, *args, &block
    ActiveSupport::Notifications.instrument(name, args, &block)
  end

  def self.subscribe to, worker = nil, &block
    if block_given?
      ActiveSupport::Notifications.subscribe(to, &block)
    else
      ActiveSupport::Notifications.subscribe to do |event_name, *ignore, args|
        worker.perform event_name, *args
      end
    end
  end

end