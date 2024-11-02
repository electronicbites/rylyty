##
# The STI class for a photo task (aka question)
#
class PhotoTask < Task
  attr_accessible :question

  def find_latest_advertised_answers limit=10
    find_latest_answers 10
  end
end