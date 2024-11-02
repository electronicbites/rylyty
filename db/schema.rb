# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130110191732) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "username"
    t.string   "string"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "badge_contexts", :force => true do |t|
    t.datetime "created_at"
  end

  create_table "badgeable_events", :force => true do |t|
    t.integer "badge_id"
    t.integer "event_source_id"
    t.string  "event_source_type"
    t.string  "context"
  end

  create_table "badges", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.hstore   "context"
  end

  add_index "badges", ["context"], :name => "index_badges_on_context"

  create_table "beta_users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "confirmation_token"
    t.datetime "confirmation_sent_at"
    t.datetime "confirmed_at"
    t.boolean  "newsletter"
  end

  create_table "download_links", :force => true do |t|
    t.string   "url"
    t.string   "sha"
    t.string   "bundle"
    t.integer  "num_downloads"
    t.datetime "created_at"
  end

  create_table "downloads", :force => true do |t|
    t.integer  "download_link_id"
    t.datetime "created_at"
    t.string   "client_ip"
    t.string   "user_agent"
    t.string   "udid"
  end

  create_table "feed_items", :force => true do |t|
    t.text          "message"
    t.datetime      "created_at",      :null => false
    t.datetime      "updated_at",      :null => false
    t.string        "feed_visibility"
    t.integer       "sender_id"
    t.string        "event_type"
    t.integer_array "receiver_ids"
    t.integer       "feedable_id"
    t.string        "feedable_type"
  end

  create_table "friendships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "friendships", ["friend_id"], :name => "index_friendships_on_friend_id"
  add_index "friendships", ["user_id", "friend_id"], :name => "index_friendships_on_user_id_and_friend_id"
  add_index "friendships", ["user_id"], :name => "index_friendships_on_user_id"

  create_table "games", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "time_limit"
    t.integer  "costs"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "short_description"
    t.integer  "author_id"
    t.integer  "minimum_age"
    t.integer  "min_points_required"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "quest_id"
    t.text     "suggestion"
    t.integer  "points",               :default => 0, :null => false
    t.integer  "restriction_points",   :default => 0, :null => false
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.integer  "restriction_badge_id"
    t.integer  "reward_badge_id"
  end

  create_table "games_tags", :force => true do |t|
    t.integer "game_id"
    t.integer "tag_id"
  end

  create_table "invitations", :force => true do |t|
    t.string   "token"
    t.string   "email"
    t.datetime "sent_at"
    t.datetime "accepted_at"
    t.integer  "invitee_id"
    t.integer  "invited_by_id"
    t.integer  "invited_to"
    t.integer  "beta_invitations_budget"
    t.integer  "download_link_id"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "invitations", ["email", "invited_by_id"], :name => "index_invitations_on_email_and_invited_by_id", :unique => true
  add_index "invitations", ["invited_by_id"], :name => "index_invitations_on_invited_by_id"
  add_index "invitations", ["invitee_id", "invited_by_id"], :name => "index_invitations_on_invitee_id_and_invited_by_id", :unique => true
  add_index "invitations", ["invitee_id"], :name => "index_invitations_on_invitee_id"
  add_index "invitations", ["token"], :name => "index_invitations_on_token", :unique => true

  create_table "likes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "user_task_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "mission_games", :force => true do |t|
    t.integer "mission_id"
    t.integer "game_id"
  end

  create_table "missions", :force => true do |t|
    t.integer  "start_points", :default => 0
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  create_table "pg_search_documents", :force => true do |t|
    t.text     "content"
    t.integer  "searchable_id"
    t.string   "searchable_type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "photo_questions", :force => true do |t|
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "quests", :force => true do |t|
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "tags", :force => true do |t|
    t.string "value"
    t.string "context"
  end

  add_index "tags", ["context"], :name => "index_tags_on_context"

  create_table "tasks", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "game_id"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.text     "type",               :default => "QuestionTask", :null => false
    t.text     "question"
    t.string   "short_description"
    t.integer  "position"
    t.integer  "timeout_secs"
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.integer  "points",             :default => 0,              :null => false
    t.boolean  "user_task_viewable", :default => true
    t.boolean  "optional",           :default => false
  end

  add_index "tasks", ["game_id"], :name => "index_tasks_on_game_id"

  create_table "user_badge_events", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at",         :null => false
    t.integer  "badgeable_event_id"
  end

  create_table "user_badges", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "badge_id",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "user_games", :force => true do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.string   "state"
    t.datetime "started_at"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "feed_visibility", :default => "community"
    t.datetime "finished_at"
  end

  add_index "user_games", ["game_id"], :name => "index_user_games_on_game_id"
  add_index "user_games", ["user_id", "game_id"], :name => "index_user_games_on_user_id_and_game_id"
  add_index "user_games", ["user_id"], :name => "index_user_games_on_user_id"

  create_table "user_missions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "mission_id"
    t.integer  "points",     :default => 0
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "user_tasks", :force => true do |t|
    t.integer  "task_id"
    t.integer  "user_game_id"
    t.text     "comment"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "state"
    t.string   "verification_state"
    t.integer  "user_id"
    t.text     "answer"
    t.text     "type"
    t.text     "photo_file_name"
    t.text     "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.integer  "position"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.text     "approval_state"
    t.datetime "times_out_at"
    t.boolean  "optional",           :default => false
    t.text     "reward"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                   :default => "", :null => false
    t.string   "encrypted_password",      :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "username"
    t.integer  "user_points",             :default => 0
    t.date     "birthday"
    t.integer  "credits",                 :default => 0
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.text     "facebook_id"
    t.text     "facebook_profile_url"
    t.integer  "beta_invitations_budget", :default => 0
    t.integer  "beta_invitations_issued", :default => 0
    t.integer  "device_token"
    t.datetime "last_apn_send_date"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
