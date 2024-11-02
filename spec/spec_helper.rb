require 'rails/application'

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'email_spec'
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/email/rspec'
require 'capybara-screenshot'
require 'headless' if ENV['HEADLESS']
require 'database_cleaner'
require 'resque_spec/scheduler'
require 'vcr'


Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }


Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

RSpec.configure do |config|
  # http://stackoverflow.com/questions/8178120/capybara-with-js-true-causes-test-to-fail
  config.use_transactional_fixtures = false
  
  config.mock_with :flexmock
  Capybara.javascript_driver = :webkit
  config.include Devise::TestHelpers, type: :controller
  # config.include Warden::Test::Helpers, type: :request
  config.include LoginHelper, type: :request
  config.include TestDataHelper, type: :request
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers
  #config.extend VCR::RSpec::Macros
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.before(:suite) do
    if defined?(Headless)
      @headless = Headless.new
      @headless.start
    end
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    # http://stackoverflow.com/questions/8178120/capybara-with-js-true-causes-test-to-fail
    if Capybara.current_driver == :rack_test
      DatabaseCleaner.strategy = :transaction
    else
      DatabaseCleaner.strategy = :truncation
    end
    DatabaseCleaner.start
    Resque.inline = true
  end

  config.after(:each) do
    Resque.inline = false
    DatabaseCleaner.clean
  end

  config.around(:each, :vcr) do |example|
    name = example.metadata[:full_description].split(/\s+/, 2).join("/").underscore.gsub(/[^\w\/]+/, "_")
    options = example.metadata.slice(:record, :match_requests_on).except(:example_group)
    VCR.use_cassette(name, options) { example.call }
  end

  config.after(:suite) do
    @headless.destroy if @headless
  end
end

def parse_json
  ActiveSupport::JSON.decode(response.body)
end

def wait_for_ajax
    wait_until do
      (page.evaluate_script('$.active') == 0).tap do |res|
        #puts 'waiting for ajax call to be completed..' unless res
      end
    end
  end