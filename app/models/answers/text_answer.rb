##
# This is the answer to a "QuestionTask"
#
class TextAnswer < UserTask

  attr_accessible :answer

  def self.match_task? task
    task.class <= QuestionTask
  end

  ##
  # A +TextAnswer+ is considered as answered, when the {#answer} is not empty
  #
  # @return [Boolean]
  def answered?
    answer?
  end
end

UserTask.register_answer TextAnswer