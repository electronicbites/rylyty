class DevelopmentMailInterceptor
  def self.delivering_email(message)
    overwrite_to = ENV['ACTION_MAILER_OVERWRITE_RECIPIENT'] || 'devs@rylyty.com'

    Rails.logger.info "Intercepting Mail. Reroute from #{message.to} to #{overwrite_to}"
    message.to  = overwrite_to
    message.bcc = nil if message.bcc
    message.cc  = nil if message.cc
  end
end

Dotenv.load '.env', '.env.development'

Geddupp::Application.configure do

  config.action_mailer.default_url_options = { :host => ENV['ACTION_MAILER_DEFAULT_HOST'] || 'localhost:3000' }
  config.action_mailer.smtp_settings = {
    :address   => "smtp.mandrillapp.com",
    :port      => 587,
    :user_name => ENV["MANDRILL_USERNAME"],
    :password  => ENV["MANDRILL_APIKEY"]
  }
  ActionMailer::Base.register_interceptor DevelopmentMailInterceptor

  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.paperclip_defaults = {
    url: "/assets/:attachment/:class/:id/:style/:filename"
  }
end

require "i18n/backend/fallbacks"
I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)