class Invitation < ActiveRecord::Base

  module EventTypes
    INVITE_ACCEPTED       = 'invite_accepted'
    GAME_INVITE_RECEIVED  = 'game_invite_received'
  end

  belongs_to :invitee, class_name: "User"     # The user invited to smth.
  belongs_to :invited_by, class_name: "User"  # The user who invited someone else
  belongs_to :invited_to, polymorphic: true
  belongs_to :download_link

  attr_accessible :accepted_at, :email, :sent_at, :token,
                  :invitee, :invited_by, :invited_to,
                  :beta_invitations_budget

  validates :token,   presence: true, if: Proc.new { |i| i.email.present? }
  validates :invitee, presence: true, if: Proc.new { |i| !i.email.present? }
  validates :email,   presence: true, if: Proc.new { |i| !i.invitee.present? }
  validates :email,   allow_nil: true, format: Devise.email_regexp
  validate  :cannot_invite_herself

  before_validation :ensure_existing_invitee, :ensure_accepted_date, :ensure_token, :ensure_beta_invitations_budget
  after_create :send_invitation

  scope :not_accepted, where(accepted_at: nil)

  class << self

    ##
    # @param [Symbol] The column to generate the token for
    # @param [Fixnum] The aproximate length of the generated token
    #                 default: 30 will generate 40 chars
    #                 (see +SecureRandom::urlsafe_base64+)
    def generate_token column, length = 30
      loop do
        token = SecureRandom.urlsafe_base64(length)
        break token unless Invitation.where({ column => token }).first
      end
    end
  end

  def accepted?
    (!accepted_at.nil?) || download_link.present?
  end

  def initial_beta_invite?
    !invited_by.present?
  end

  ##
  # accepts the invitation
  # @param [User] the user who accepted the invitaion
  def accept! new_user, is_new_registration = false
    return false unless can_be_accepted_by?(new_user)
    self.invitee = new_user
    self.download_link = DownloadLink.create num_downloads: 3
    self.accepted_at = DateTime.now
    self.send_invitation_notification is_new_registration
    save!
    if self.invited_by
      self.invited_by.become_friends_with self.invitee if is_new_registration
      self.invited_by.earn_credits 50 #write a config for all the random credit stuff maybe
      self.send_invitation_notification is_new_registration
      Notifications.publish('set_invitation_accepted_badges', for: self) if is_new_registration
    end
    self
  end

  def can_be_accepted_by? user
    !accepted? &&
    (!invited_by || user.id != invited_by.id) &&
    !Invitation.where("accepted_at IS NOT NULL AND invitee_id = ?", user.id).exists?
  end

  ##
  # Send's the initial invitation to a not registered user.
  # Send's mail only, when the invitation was not yet accepted and
  # a email address is present (which indicates a not registered user)
  def send_invitation_mail
    options = {}
    
    if self.invited_to
      options.merge!({
        deeplink: deeplink
      })
    end
    InvitationMailer.invited(self.email, self.id, options).deliver if !self.accepted? && self.email.present?
  end

  ##
  # Send's the reminder mail where/how to install the beta-app.
  # Send's mail only, when invitation has been accepted
  def send_beta_download_reminder_mail
    InvitationMailer.beta_download_reminder(self.id) if self.accepted?
  end


  def send_invitation_notification is_new_registration = false
    if (!self.invited_to.nil? && self.invited_to.kind_of?(Game) && !is_new_registration)
      Notifications.publish 'write_my_news_feed_item', 
        reference: self.invited_to, 
        sender: self.invited_by, 
        receiver_ids: [self.invitee.id], 
        event_type: Invitation::EventTypes::GAME_INVITE_RECEIVED, 
        visibility: 'friends', 
        feedable: self.invited_to
    else
      Notifications.publish 'write_my_news_feed_item',
        reference: self,
        sender: self.invitee,
        receiver_ids: [self.invited_by_id],
        event_type: Invitation::EventTypes::INVITE_ACCEPTED,
        visibility: 'friends',
        feedable: self.invitee
    end
  end

  # set deeplink to what ever here, this is not working at the moment
  def deeplink auth_token=nil
    "deeplink:#{invited_to_type}=#{invited_to_id}" << "auth=#{auth_token}" #if auth_token
  end

  private

    def send_invitation
      if email.present?
        send_invitation_mail
      else
        send_invitation_notification is_new_registration=false
      end
    end

    def ensure_existing_invitee
      self.email = nil if invitee.present?
      return if !email.present?

      existing_user = User.where(email: email).first
      if existing_user
        self.invitee = existing_user
        self.email = nil
      end
    end

    def ensure_token
      self.token = Invitation.generate_token(:token) if !token && email.present?
    end

    def ensure_beta_invitations_budget
      return unless beta_invitations_budget.nil?

      self.beta_invitations_budget = if invited_by
        invited_by.beta_invitations_budget / 3
      else
        10
      end
    end

    def ensure_accepted_date
      self.accepted_at = DateTime.now if self.download_link.present? && !self.accepted_at
    end

    def cannot_invite_herself
      return if !invited_by.present?
      e = "cannot invite herself"
      errors.add(:invitee, e) if invitee.present? && invited_by.id == invitee.id
      errors.add(:email, e) if email.present? && invited_by.email == email
    end
end
