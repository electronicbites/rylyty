require 'spec_helper'

describe 'routing to user-tasks' do

  it '/api/v1/users/123/tasks' do
    {get: '/api/v1/users/123/tasks'}.should route_to(
      controller: 'api/v1/user_tasks',
      action: 'index',
      user_id: '123'
    )
  end

  it '/api/v1/users/23/tasks/42/like' do
    {post: '/api/v1/users/23/tasks/42/like'}.should route_to(
      controller: 'api/v1/user_tasks',
      action: 'like',
      user_id: '23',
      id: '42'
    )
  end

  it '/api/v1/users/23/tasks/42/unlike' do
    {post: '/api/v1/users/23/tasks/42/unlike'}.should route_to(
      controller: 'api/v1/user_tasks',
      action: 'unlike',
      user_id: '23',
      id: '42'
    )
  end

  it '/api/v1/tasks/123/report' do
    { post: 'api/v1/users/123/tasks/123/report'}.should route_to(
        controller: 'api/v1/user_tasks',
        action: 'report',
        task_id: '123',
        user_id: '123'
      )
  end

  it '/api/v1/tasks/123/block' do
    { post: 'api/v1/users/123/tasks/123/block'}.should route_to(
        controller: 'api/v1/user_tasks',
        action: 'block',
        task_id: '123',
        user_id: '123'
      )
  end

end
