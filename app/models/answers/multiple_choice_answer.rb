class MultipleChoiceAnswer < UserTask

  attr_accessible :answers

  def self.match_task? task
    task.class <= MultipleChoiceTask
  end

  ##
  # A +MultipleChoiceAnswer+ is considered as answered, when
  # the test is considered as passed ({#passed?})
  #
  # @return [Boolean]
  def answered?
    passed?
  end

  # not sure if we need to overwrite {#answer_with}
  # or we can simply relay on parent's {#update_attributes} to set
  # +answers+ (with trailing 's')
  # def answer_with answer_attributes
  #   self.answers = answer_attributes
  #   complete
  # end

  ##
  # returns a single Hash mapping Question-Indexes on Answer-Indexes
  #
  # @example Questions at index 2 was not answered
  #   { "0" => [1], "1" => [0,2], "3" => [2] }
  #
  # @return [Hash]
  def answers
    answer[:answers] || {}
  end

  ##
  # Set the users' answers and (re)calculate the test score.
  #
  # @param [Hash] Mapping question indexes on a answer +Array<Fixnum>+
  #
  # @example Answers are: First question answered with 2nd and 3rd answer. Third question answered with first answer. Second and Fourth question not answered.
  #   user_task.answers = { "0" => [1,2], 2 => [0], 3 => [] }
  def answers=(hsh)
    a = self.answer
    hsh = hsh.first if hsh.is_a?(Array)
    hsh.each{|key,value| hsh[key] = [value.to_i] unless value.is_a?(Array)} #convert values to array if they arent
    a[:answers] = hsh.delete_if{ |k,v| !v || v.empty? }

    # recalculate score when answers where written
    a[:score] = self.calculate_score a[:answers] unless ignore_scoring?

    self.answer = a
  end

  ##
  # The score of this test. This is the sum of all point of all
  # correctly answered questions in this task.
  # The score will be calculated when answers are beeing set.
  #
  # @return [Fixnum, nil] The score, or +nil+ if no score can be
  #    calculated yet (due to missing answers) or the task does not
  #    require scroing (see {#ignore_scoring?})
  def score
    nil if !answer[:score].present?
    answer[:score].to_i rescue 0
  end

  ##
  # Whether the +Task+ does not require a scoring
  #
  # @return [Boolean]
  def ignore_scoring?
    !task.minimum_score?
  end

  ##
  # determinate if the whole multiple choice test is passed
  # this is, when:
  #   1. the test was answered
  #   2. the sum of the points of all currect
  #      answers equals or exceeds the +minimum_score+ value
  #      of the +MultipleChoiceTask+
  #
  # @note Shortcuts to +true+ if the +Task+ does not require a minimum score.
  #
  # @return [Boolean]
  def passed?
    !self.answers.empty? && (ignore_scoring? || task.minimum_score <= self.score)
  end

  ##
  # determinate if a single question was answered correctly, this is
  # when all correct answers where given, and none of the incorrect
  #
  # @param [Fixnum] The index of the queestion
  # @paran [Array<Fixnum>] Array of given (checked in) answers
  #
  # @return [Boolean] Whether the question was answered correctly
  def correct? question_idx, answer_idxs
    question_idx = question_idx.to_i
    answer_idxs = answer_idxs.map(&:to_i).uniq

    correct_idxs = task.questions[question_idx][:options].each_with_index.inject([]) do |memo, val|
      option, index = val
      memo << index.to_i if option[:check] && (option[:check] == true || option[:check].to_i > 0)
      memo
    end

    correct_idxs == answer_idxs.sort
  end

  protected

    def answer
      JSON.parse(read_attribute(:answer), symbolize_names: true) rescue {}
    end

    def answer=(hsh)
      write_attribute(:answer, hsh.to_json)
    end

    ##
    # Sums up the points of all correctly answered questions
    #
    # @return [Fixnum] The calculated score
    def calculate_score answers_hsh
      answers_hsh.inject(0) { |sum, val|
        question_idx, answer_idxs = val
        sum += self.task.points_for(question_idx) if self.correct? question_idx, answer_idxs
        sum
      }
    end
end

UserTask.register_answer MultipleChoiceAnswer