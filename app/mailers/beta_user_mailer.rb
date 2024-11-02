class BetaUserMailer < ActionMailer::Base
  def register_beta_user beta_user
    @beta_user = beta_user
    mail to: @beta_user.email, subject: 'Deine Anmeldung bei rylyty.com', from: 'info@rylyty.com', template_name: 'register_beta_user'
  end
end

