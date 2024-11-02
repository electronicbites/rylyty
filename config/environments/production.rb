Geddupp::Application.configure do

  config.cache_classes = true

  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.serve_static_assets = false
  config.assets.compress = true

  config.assets.compile = false
  config.assets.digest = true

  config.assets.precompile += %w( _bootstrap.css _bootstrap-responsive.css temporary-tweaks.css active_admin.css active_admin/print.css active_admin.js game_editor.css invitation.css)
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify

  config.action_mailer.default_url_options = { :host => ENV['ACTION_MAILER_DEFAULT_HOST'] || 'www.rylyty.com'}
  config.action_mailer.smtp_settings = {
    :address   => "smtp.mandrillapp.com",
    :port      => 25,
    :user_name => ENV["MANDRILL_USERNAME"],
    :password  => ENV["MANDRILL_APIKEY"]
  }
  config.paperclip_defaults = {
    :storage => :s3,
    :url => ":s3_domain_url",
    :s3_credentials => {
      :bucket => ENV['AWS_BUCKET'],
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    }
  }
end

