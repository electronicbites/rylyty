require 'resque/tasks'
require 'resque_scheduler/tasks'

task "resque:setup" => :environment
task "resque:scheduler_setup" => :environment

task "jobs:work" => "resque:scheduler"
