module ApplicationHelper
  def cur_a_or_b
    request.env[ApplicationController::REQ_KEY_CUR_A_B]
  end
end
