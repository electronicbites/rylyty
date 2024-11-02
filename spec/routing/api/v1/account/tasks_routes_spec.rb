require 'spec_helper'

describe 'routing to my/tasks' do
  it '/api/v1/my/tasks/123/send_photo' do
    {post: '/api/v1/my/tasks/123/answer'}.should route_to(
      controller: 'api/v1/account/tasks',
      action: 'answer',
      task_id: '123'
    )
  end

  it '/api/v1/my/tasks/123/start' do
    {post: '/api/v1/my/tasks/123/start'}.should route_to(
      controller: 'api/v1/account/tasks',
      action: 'start',
      task_id: '123'
    )
  end

  it '/api/v1/my/tasks/123/cancel' do
    {post: '/api/v1/my/tasks/123/cancel'}.should route_to(
      controller: 'api/v1/account/tasks',
      action: 'cancel',
      task_id: '123'
    )
  end

  it '/api/v1/my/tasks/123' do
    {get: '/api/v1/my/tasks/123'}.should route_to(
      controller: 'api/v1/account/tasks',
      action: 'show',
      id: '123'
    )
  end

  it '/api/v1/my/tasks/123' do
    {put: '/api/v1/my/tasks/123'}.should route_to(
      controller: 'api/v1/account/tasks',
      action: 'update',
      id: '123'
    )
  end
end