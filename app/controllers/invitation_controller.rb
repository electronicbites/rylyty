class InvitationController < Devise::RegistrationsController
  include BetaDownloadHelper

  before_filter :ensure_invitation_token
  layout 'invitation'

  def new
    return redirect_to completed_user_registration_path if @invitation.accepted?
    super
  end

  def create
    return redirect_to completed_user_registration_path if @invitation.accepted?
    super
  end

  # hook into the sign up process
  def sign_in(resource_name, resource)
    return redirect_to completed_user_registration_path if !@invitation.accept!(resource, true)
    super
  end

  def mail_beta_download_reminder
    @invitation.send_beta_download_reminder_mail
    redirect_to mail_beta_download_reminder_success_path
  end

  def mail_beta_download_reminder_success; end

  def completed
    # simple render
    # @todo: switch when iPhone detected
    if request.env['X_MOBILE_DEVICE']
      return render :'completed.iphone'
    end
  end

  protected

    def build_resource(hash=nil)
      hash = {'email' => @invitation.email}.merge(resource_params || {}) if !hash || hash.empty?
      super
    end

    def ensure_invitation_token
      unless (@invitation = Invitation.find_by_token (params[:token] || cookies[:invitation_token]))
        render :'invalid_token'
        return false
      end
      cookies[:invitation_token] ||= {value: @invitation.token, expires: 15.minutes.from_now}
    end

    def after_sign_in_path_for(resource_or_scope)
      ensure_invitation_token
      completed_user_registration_path
    end

    # overwriting DeviseController#set_flash_message
    def set_flash_message(key, kind, options={})
      return if kind.to_s.start_with? 'signed_up'
      super
    end
end
