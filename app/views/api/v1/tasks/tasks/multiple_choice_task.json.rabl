object :@task

attributes :minimum_score

node (:ignore_scoring) { |task| !task.minimum_score? }
node (:questions) { |task|
  # extend questions and answers with an index
  task.questions.each_with_index.map { |q, idx|
    q[:options].each_with_index.map { |a, idx|
      a.tap { |a| a[:order] = idx }
    }
    q.tap { |q| q[:order] = idx }
  }
}
