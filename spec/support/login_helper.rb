module LoginHelper
  def sign_in_as user
   post '/api/v1/login', login: user.username, password: user.password
  end
  def sign_in_as_admin admin_user, clear_text_pwd 
   visit admin_user_session_path
   fill_in "admin_user[login]", with: admin_user.username
   fill_in "admin_user[password]", with: clear_text_pwd
   click_button "Login"
  end
end