source 'https://rubygems.org'
ruby '2.1.10'
gem 'rails', '3.2.19'


gem 'activeadmin'
gem 'activerecord-postgres-hstore'
gem 'acts_as_list'
gem 'airbrake'
gem 'apn_sender', require: 'apn'
gem 'ar_pg_array'
gem 'aws-sdk'
gem 'devise', '= 2.1.2'
gem 'haml', '>= 3.0.0'
gem 'haml-rails'
gem 'jquery-rails'
gem 'koala'
gem 'paperclip', "~> 3.0"
gem 'nokogiri', "~> 1.6"
gem 'pg'
gem 'pg_search'
gem 'rabl-rails'
gem 'rack-mobile-detect', require: 'rack/mobile-detect'
gem 'resque-scheduler', require: 'resque_scheduler'
gem 'resque_mailer'
gem 'state_machine'
gem 'unicorn'
gem 'rb-readline'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails'
  gem 'bootstrap-sass'
  gem 'haml_assets', '>= 0.1.0'
  gem 'handlebars_assets'
  gem 'sass'
  gem 'sass-rails'
  gem 'uglifier', '>= 1.0.3'
end

group :production do
  gem 'newrelic_rpm', '>= 3.5.4'
  gem 'rpm_contrib'
end

group :development, :test do
  gem 'database_cleaner'
  gem 'headless', require: false
  gem 'capybara'
  gem 'capybara-email'
  gem 'capybara-screenshot', require: false
  gem 'capybara-webkit'
  gem 'email_spec'
  gem 'factory_girl_rails'
  gem 'rspec-rails', '>= 2.11.0'
  gem 'therubyracer'
  gem 'test_after_commit'
  gem 'resque_spec', :require => "resque_scheduler"
  gem 'dotenv'
  gem 'sandbox', :path => 'lib/sandbox'
end

group :test do
  gem 'flexmock'
  gem 'faraday'
  gem 'vcr'
end
