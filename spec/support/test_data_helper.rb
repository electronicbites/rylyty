module TestDataHelper

  def create_photo_task_completed_by_ten_users 
    task = FactoryGirl.create(:photo_task)
    users = FactoryGirl.create_list(:user, 10)
    user_games = []

    users.each do |user|
      user_games << FactoryGirl.create_list(
        :user_game, 1, 
        user: user, 
        user_tasks: FactoryGirl.create_list(:user_task_verified, 1, task: task, user: user, type: 'PhotoAnswer')
      )
    end
    task
  end

  def create_photo_task_completed_by_ten_users_five_blocked 
    task = FactoryGirl.create(:photo_task)
    users = FactoryGirl.create_list(:user, 10)
    user_games = []

    users.each_with_index do |user, idx|
      
      factory = :user_task_verified
      factory = :user_task_verified_but_blocked unless idx % 2 == 0 

      user_games << FactoryGirl.create_list(
        :user_game, 1, 
        user: user, 
        user_tasks: FactoryGirl.create_list(factory, 1, task: task, user: user, type: 'PhotoAnswer')
      )
    end

    task
  end
end