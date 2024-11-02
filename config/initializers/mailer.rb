require 'mailer_config'
MailerConfig.config = YAML.load_file(Rails.root + "config/mailer.yml")[Rails.env]
