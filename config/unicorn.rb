worker_processes 3
preload_app true
timeout 30

before_fork do |server, worker|
  if defined?(Resque)
    Resque.redis.quit
    Rails.logger.info('Disconnecting from Redis')
  end

  sleep 1
end

after_fork do |server, worker|
  if defined?(Resque)
    Resque.connect
    Rails.logger.info('Connecting to Redis')
  end
end

