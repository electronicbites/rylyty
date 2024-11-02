require "bundler/capistrano"
require 'airbrake/capistrano'

set :application, "geddupp"
set :user, "ubuntu"

set :scm, :git
set :repository,  "git@github.com:geddupp/geddupp-rails.git"
set :branch, "master"
set :deploy_via, :copy
set :deploy_strategy, :export

set :deploy_to, "/srv/geddupp/rails"
set :use_sudo, false
set :keep_releases, 7

role :web, "54.247.76.34"
role :app, "54.247.76.34"
role :db,  "54.247.76.34", :primary => true


after "deploy:restart", "deploy:cleanup"