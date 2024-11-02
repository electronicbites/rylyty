class PhotoAnswer < UserTask
  has_attached_file :photo, styles: { thumb_hi: "180x180>", thumb: "90x90>" },
      path: ":rails_root/public/assets/tasks/:task_id/:user_id/:style"

  attr_accessible :photo
  alias_attribute :comment, :answer

  # custom placeholder for photo-attachment-url
  Paperclip.interpolates :task_id do |attachment, style|
    attachment.instance.try(:task).try(:id) || -1
  end

  # custom placeholder for photo-attachment-url
  Paperclip.interpolates :user_id do |attachment, style|
    attachment.instance.try(:user).try(:id) || -1
  end

  def self.match_task? task
    task.class <= PhotoTask
  end

  ##
  # A +PhotoAnswer+ is considered as answered, when there
  # is a uploaded photo ({#photo?})
  #
  # @return [Boolean]
  def answered?
    photo?
  end
end

UserTask.register_answer PhotoAnswer