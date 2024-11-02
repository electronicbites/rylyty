Geddupp::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config
  namespace :admin do
    resources :games #, only: [:edit, :update] do
  end
  authenticate :admin_user do
    mount Resque::Server, at: '/cockpit/resque'
  end
  namespace :api do
    namespace :v1 do
      devise_for :users, :controllers => {registrations: 'registrations', sessions: 'sessions', passwords: 'devise/passwords' }
      devise_scope :user do
        post '/signup' => 'registrations#create', as: :signup
        post '/login' => 'sessions#create', as: :user_session
        post '/login_with_facebook' => 'sessions#create_with_facebook', as: :user_session
        match '/logout' => 'sessions#destroy', as: :destroy_user_session
      end

      resources :missions, only: [:index, :show] do
        resources :games, only: [:index]
      end
      resources :games, only: [:index, :show] do
        post '/buy' => 'games#buy'
        resources :tasks, only: [:index]
      end
      resources :tasks, only: [:show]

      get '/users/check_username' => 'users#check_username'
      resources :users, only: [:show] do
        resources :friends, only: [:index]
        resources :tasks, only: [:index], controller: "user_tasks" do
          member do
            post :like
            post :unlike
          end
          post '/report' => 'user_tasks#report'
          post '/block' => 'user_tasks#block'
        end
      end

      # resources :users, only: [:show] do
      #   resources :friends, only: [:index]
      # end

      post '/account/request_password_reset' => 'users#request_password_reset'

      resources :quests, only: [:index, :show] do
        resources :games, only: [:index]
      end
      resources :categories, only: [:index]
      # my account namespace
      namespace :my, module: :account do
        resources :tasks, only: [:index, :show, :update] do
          post '/start' => 'tasks#start'
          post '/cancel' => 'tasks#cancel'
          post '/answer' => 'tasks#answer'
        end
        resources :friends, only: :index
        resources :badges, only: :index
        resources :games, only: [:index, :show] do
          put  '/privacy' => 'games#update_privacy'
        end
        # /feeds/games/:game_id # news for a spec. game of the logged in user
        # /feeds/games?start=:feed_item_id # news for all games of the logged in user
        get 'feeds/games' => 'feed_items#games'
        get 'feeds/news' => 'feed_items#news'
        get 'feeds/friends' => 'feed_items#friends'

        post 'profile/add_facebook_id' => 'users#add_facebook_id'
        post 'profile/facebook_friends' => 'users#facebook_friends'
        post 'profile/add_friends' => 'users#add_friends'
        post 'profile/find_friends' => 'users#find_friends'

        put 'profile' => 'users#update'
      end
      get  'system/info' => 'system#info'

      resources :invitations, only: [:create]
    end
  end

  devise_for :users, :skip => [:sessions], :controllers => {:registrations => "invitation"}, :path_names => {:registration => "invitation", :sign_up => 'accept'}
  devise_scope :user do
    get '/users/invitation/completed' => 'invitation#completed', as: :completed_user_registration
    post '/users/invitation/mailme' => 'invitation#mail_beta_download_reminder', as: :mail_beta_download_reminder
    get '/users/invitation/mailme/send' => 'invitation#mail_beta_download_reminder_success', as: :mail_beta_download_reminder_success
  end

  resources :beta_users, only: [:create, :confirm]
  get "/beta_users/:confirmation_token/confirm" => "beta_users#confirm", as: :beta_user_confirmation
  get "/get-beta/:sha/manifest.plist" => "download#get_beta_manifest", as: :download_manifest_beta_app
  get "/get-beta/:sha" => "download#get_beta", as: :download_beta_app

  get '/impressum' => 'home#impressum', as: :impressum
  get '/agb' => 'home#agb', as: :agb
  get '/dse' => 'home#datenschutzerklaerung', as: :datenschutzerklaerung
  match "/blog" => redirect("http://blog.rylyty.com/"), :as => :blog
  if Rails.env.development?
    mount Sandbox::Engine => "/sandbox"
  end
  root :to => 'home#index'
end
