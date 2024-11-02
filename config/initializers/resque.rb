require 'resque/server'

# This will make the scheduler-tabs show up.
require 'resque_scheduler'
require 'resque_scheduler/server'

Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }

rails_root = Rails.root || File.dirname(__FILE__) + '/../..'
resque_config = YAML.load_file(rails_root.to_s + '/config/resque.yml')

rails_env = Rails.env || 'development'
ENV["REDISTOGO_URL"] ||= (resque_config[rails_env] || resque_config['production'])['redis_url']

uri = URI.parse(ENV["REDISTOGO_URL"])
Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password, :thread_safe => true)

# http://stackoverflow.com/questions/9961044/postgres-error-on-heroku-with-resque
Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }
