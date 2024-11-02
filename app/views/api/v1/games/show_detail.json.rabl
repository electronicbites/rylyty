object :@game => :game

extends '/api/v1/games/show_simple'


child(:tasks) {
  extends "/api/v1/tasks/index"
}

