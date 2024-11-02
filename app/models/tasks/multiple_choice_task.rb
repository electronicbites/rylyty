##
# The STI class for a Multiple Choice _Test_
# this test consists of multiple questions, with multiple possible answers each!
class MultipleChoiceTask < Task
  attr_accessible :questions, :minimum_score
  ##
  # The whole questions-to-answers +Hash+
  #
  # @return [Hash] The questions-to-answers mapping
  def questions
    question[:questions] || []
  end

  ##
  # Set the multiple choice questions-to-answers +Hash+
  #
  # @param [Hash] The questions-to-answers mapping
  #
  # @example Some facts taken from https://en.wikipedia.org/wiki/Multiple_choice
  #   [
  #     {
  #       question: "If a=1, b=2. What is a+b?",
  #       points: 1,
  #       options: [
  #         { answer: "12", check: false },
  #         { answer: "3", check: true },
  #         { answer: "4", check: false },
  #       ]
  #     },{
  #       question: "Ruby ia a",
  #       points: 5,
  #       options: [
  #         { answer: "dynamic language", check: true },
  #         { answer: "cool", check: true },
  #         { answer: "none of the above", check: false },
  #       ]
  #     },{
  #       question: "Consider the following:
  #
  #       I. An eight-by-eight chessboard.
  #      II. An eight-by-eight chessboard with two opposite corners removed.
  #     III. An eight-by-eight chessboard with all four corners removed.
  #
  #   Which of these can be tiled by two-by-one dominoes (with no overlaps or gaps, and every domino contained within the board)?",
  #       points: 10,
  #       options: [
  #         { answer: "I only", check: false },
  #         { answer: "I and II only", check: false },
  #         { answer: "I and III only", check: true },
  #       ]
  #     }
  #   ]
  def questions=(ary)
    q = self.question
    q[:questions] = ary
    self.question = q
  end

  ##
  # Return the points earned, when the given question was answered correctly
  #
  # @param [Fixnum] The index of the question
  #
  # @return [Fixnum] The possible number of points
  def points_for question_idx
    questions[question_idx.to_i][:points].to_i rescue 0
  end

  ##
  # The score (sum of all point) a user must have earned by correctly answering
  # the questions in this task to pass it
  #
  # @return [Fixnum] The number op points
  def minimum_score
    question[:minimum_score].to_i rescue 0
  end

  ##
  # ActiveRecord like helper method to determinate if there is a +minimum_score+ set
  #
  # @return [Boolean]
  def minimum_score?
    minimum_score > 0
  end

  def minimum_score=(points)
    q = self.question
    q[:minimum_score] = points
    self.question = q
  end

  protected
    # You shall not access the questions JSON directly
    def question
      JSON.parse(read_attribute(:question), symbolize_names: true) rescue {}
    end

    def question=(hsh)
      write_attribute(:question, hsh.to_json)
    end

end