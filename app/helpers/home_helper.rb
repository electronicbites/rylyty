module HomeHelper
  def cur_a_b_t_key
    "beta_registration_index_a_or_b_#{params[:t].blank? ? '1' : params[:t]}".to_sym
  end
end
