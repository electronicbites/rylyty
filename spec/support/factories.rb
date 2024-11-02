# encoding: utf-8
FactoryGirl.define do

  sequence :email do |n|
    "email#{n}@foo.com"
  end

  sequence :username do |n|
   "foo#{n}"
  end

  sequence :facebook_id do |n|
    "123456#{n}"
  end

  sequence :name do |n|
    "##{n}"
  end

  factory :user do
    username
    password "secret"
    password_confirmation "secret"
    email
    birthday {Date.today - 18.years} #age >= 18
    user_points 125
    credits 100
    tos 'true'
    beta_invitations_budget 10
    factory :fifteen_year_old do
      birthday {Date.today - 15.years} #age >= 15
    end
    factory :almost_fifteen_year_old do
      birthday {Date.today - (15.years - 1.days)} #age >= 15
    end

    factory :user_no_credits do
      credits 0
    end

    factory :user_missing_credits do
      credits 0
    end

    factory :user_very_experienced do
      credits 1000
      user_points 1250
    end

    factory :facebook_user do
      facebook_id
    end

    factory :user_with_apn do
      device_token "8066f887538f8b993a4cfb1c0c15220dfd4118dc7f7ac3dc4e0"
    end
  end

  factory :badge do
    title 'badge-title'
  end

  factory :game do
    title "wonderfull world game"
    short_description "a world game"
    description "this is a really nice journey thru the world of games. And this cannot be denied"
    time_limit 300
    costs 25
    tasks            {FactoryGirl.build_list(:question_task, 3)}
    association :author, factory: :user
    image_file_name 'image.png'
    image_content_type "image/png"
    image_file_size 34236
    image_updated_at {Time.now - 1.week}
    icon_file_name 'image.jpg'
    icon_content_type "image/jpg"
    icon_file_size 16834
    icon_updated_at {Time.now - 1.week}
    points 25


    factory :huckepack_game do
      title "Huckepack to go"
      short_description "Du, dein Freund, zwei Passanten und eine Ampel. Die Challenge für gute Nerven und schnelle Beine."
      description "Suche dir einen Freund, den du herausforderst. Geht zu einer Kreuzung, die gut besucht und nicht zu klein ist. Überzeugt jeder einen Passanten davon, ihn Huckepack über die Straße zu tragen. 
Wenn ihr jeder einen gefunden hat und die Ampel auf grün springt, rennt ihr los. Mit eurem Passanten auf dem Rücken. Wer als erster auf der anderen Seite ist, hat gewonnen.
(Dieser Text steht für Testzwecke in jder Beschreibung)"
    end

    factory :plant_game do
      title "Guerilla-Pflanzer"
      short_description "U-Bahnhöfe, Bushaltestellen, Ampeln, Mülleimer, … sie alle haben eins gemeinsam: Sie sind grau. Voll öde eigentlich. Schnapp dir ein paar Pflanzen und ändere das!"
      description "Nimm dir einen alten Fahrradkorb, eine Bananenkiste, einen kleinen Eimer oder irgendeinen Behälter, den du nicht brauchst und der sich gut mit Draht oder am Henkel irgendwo aufhängen lässt. 
Befülle ihn mit Erde und pflanze ein paar Blumen rein. Blumen findest du beim Blumenhändler in deiner Nähe.
Suche dir jetzt einen besonders tristen Ort aus, an dem aber täglich viele Menschen vorbeigehen. Hänge dort deinen kleinen Garten auf.
(Dieser Text steht für Testzwecke in jder Beschreibung)"
    end

    factory :diver_game do
      title "Stadt-Taucher"
      short_description "Irritiere alle! Und tu so, als wäre nichts. Wer hält es am längsten durch?"
      description "Such dir ein paar Freunde. Nehmt euch jeder eine Taucherbrille. Und geht morgens mit der Taucherbrille auf dem Kopf aus dem Haus. Egal ob direkt richtig aufgesetzt oder nur oben auf der Stirn, egal. 
Die Leute werden gucken, Lehrer und Klassenkameraden werden fragen – aber ihr wisst von nichts. Verzieht keine Miene, wenn jemand fragt: „Warum hast du eine Taucherbrille auf dem Kopf?“, tut so, als habt ihr keine Ahnung, wovon derjenige redet. 
Wer hält am längsten aus?
(Dieser Text steht für Testzwecke in jder Beschreibung)"
    end

    factory :photo_game do
      tasks          {FactoryGirl.build_list(:photo_task, 3)}
    end

    factory :photo_game_with_one_task do
      tasks          {FactoryGirl.build_list(:photo_task, 1)}
    end

    factory :multiple_choice_game do
      tasks          {FactoryGirl.build_list(:multiple_choice_task, 3)}
    end

    factory :game_with_reward_badge do
      badge = FactoryGirl.create(:badge)
      game {FactoryGirl.build(:game, reward_badge_id: badge.id)}
    end
  end

  factory :task do
    sequence(:title)    { |n| "Great title ##{n}" }
    description "Are you having trouble making a good description for your game? It can be hard to describe all your hard work with just a line or two of text. That's why I'm going to be going over how to do it right in this guide."
    short_description 'Short description'
    timeout_secs 0
    points 3
    factory :question_task, class: QuestionTask

    factory :photo_task, class: PhotoTask

    factory :multiple_choice_task, class: MultipleChoiceTask do
      minimum_score 6
      questions [{
        question: "If a=1, b=2. What is a+b?",
        points: 1,
        options: [
          { answer: "12", check: false },
          { answer: "3", check: true },
          { answer: "4", check: false },
        ]
      },{
        question: "Ruby ia a",
        points: 5,
        options: [
          { answer: "dynamic language", check: true },
          { answer: "cool", check: true },
          { answer: "none of the above", check: false },
        ]
      },{
        question: "Consider the following:\n  \n    I. An eight-by-eight chessboard.\n   II. An eight-by-eight chessboard with two opposite corners removed.\n  III. An eight-by-eight chessboard with all four corners removed.\n\nWhich of these can be tiled by two-by-one dominoes (with no overlaps or gaps, and every domino contained within the board)?",
        points: 10,
        options: [
          { answer: "I only", check: false },
          { answer: "I and II only", check: false },
          { answer: "I and III only", check: true },
        ]
      }]
    end

    factory :multiple_choice_task_with_string_values, :class => MultipleChoiceTask do
      minimum_score "6"
      questions [{
        question: "If a=1, b=2. What is a+b?",
        points: "1",
        options: [ {answer: "12", check: "0"}, {answer: "3", check: "1"}, {answer: "4", check: "0"} ]
      },{
        question: "Ruby ia a",
        points: "5",
        options: [ {answer: "dynamic language", check: "1"}, {answer: "cool", check: "1"}, {answer: "none of the above", check: "0"} ]
      },{
        question: "Consider the following:\n  \n    I. An eight-by-eight chessboard.\n   II. An eight-by-eight chessboard with two opposite corners removed.\n  III. An eight-by-eight chessboard with all four corners removed.\n\nWhich of these can be tiled by two-by-one dominoes (with no overlaps or gaps, and every domino contained within the board)?",
        points: "10",
        options: [ {answer: "I only", check: "0"}, {answer: "I and II only", check: "0"}, {answer: "I and III only", check: "1"} ]
      }]
    end

    factory :multiple_choice_task_with_string_values_omitted_false, :class => MultipleChoiceTask do
      minimum_score "6"
      questions [{
        question: "If a=1, b=2. What is a+b?",
        points: "1",
        options: [ {answer: "12"}, {answer: "3", check: "1"}, {answer: "4"} ]
      },{
        question: "Ruby ia a",
        points: "5",
        options: [ {answer: "dynamic language", check: "1"}, {answer: "cool", check: "1"}, {answer: "none of the above"} ]
      },{
        question: "Consider the following:\n  \n    I. An eight-by-eight chessboard.\n   II. An eight-by-eight chessboard with two opposite corners removed.\n  III. An eight-by-eight chessboard with all four corners removed.\n\nWhich of these can be tiled by two-by-one dominoes (with no overlaps or gaps, and every domino contained within the board)?",
        points: "10",
        options: [ {answer: "I only"}, {answer: "I and II only"}, {answer: "I and III only", check: "1"} ]
      }]
    end
  end

  factory :user_game do
    user
    game
    started_at {Time.now - 10.hours}

    factory :user_game_with_3_open_tasks do
      user_tasks {FactoryGirl.build_list(:user_task, 3)}
    end

    factory :user_game_with_1_open_tasks do
      user_tasks {FactoryGirl.build_list(:photo_answer, 1)}
    end

    factory :user_game_with_1_timed_tasks do
      user_tasks {FactoryGirl.build_list(:timed_user_task, 1)}
    end

    factory :user_game_with_1_tasks_1_verified do
      user_tasks {
        FactoryGirl.build_list(:user_task, 1)
      }
    end

    factory :user_game_with_3_tasks_2_open do
      user_tasks { FactoryGirl.build_list(:user_task_completed, 1) + FactoryGirl.build_list(:user_task, 2) }
    end

    factory :user_game_with_3_tasks_1_started_1_open do
      user_tasks {
        FactoryGirl.build_list(:user_task_completed, 1) +
        FactoryGirl.build_list(:user_task_started, 1) +
        FactoryGirl.build_list(:user_task, 1)
      }
    end

    factory :user_game_with_3_tasks_1_completed_1_canceled do
      user_tasks {
        FactoryGirl.build_list(:user_task_completed, 1) +
        FactoryGirl.build_list(:user_task_canceled, 1) +
        FactoryGirl.build_list(:user_task, 1)
      }
    end

    factory :user_game_young_user do
      user {FactoryGirl.build(:fifteen_year_old)}
      user_tasks {FactoryGirl.build_list(:user_task, 3)}
    end
  end

  factory :mission do
    start_points 10
    factory :mission_with_games do
      games  {FactoryGirl.build_list(:photo_game, 5)}
    end
  end

  factory :user_task do
    # set default task with timeout - without it would be started implicitly
    task
    user_game
    comment "The daughter of a brilliant but mentally disturbed mathematician, recently deceased, tries to come to grips with her possible inheritance: his insanity. Complicating matters are one of her father's ex-students who wants to search through his papers and her estranged sister who shows up to help settle his affairs."

    factory :user_task_started do
      state :started
    end

    factory :user_task_completed do
      state :completed
    end

    factory :user_task_canceled do
      state :canceled
    end

    factory :timed_user_task do
      association :task, factory: :task, timeout_secs: 60*60*24
    end

    factory :user_task_verified do
      verification_state :verified
      state :completed
      approval_state :active
      reward "{\"task_points\":61, \"game_points\":20}"
    end

    factory :user_task_verified_but_blocked do
      verification_state :verified
      state :completed
      approval_state :blocked
    end

    factory :photo_answer, :class => PhotoAnswer do
      association :task, factory: :photo_task

      factory :completed_photo_answer, :class => PhotoAnswer do
        state :completed
        verification_state 'verified'
        approval_state 'active'
        photo_file_name 'photo.jpg'
        photo_content_type "image/jpeg"
        photo_file_size 197450
        photo_updated_at {Time.now - 1.day}
      end
    end
  end
  
  factory :download_link do
    url 'http://test.dev/:sha'
    bundle 'spec'
    num_downloads 2
  end
  
  factory :download do
  end

  factory :feed_item do
    created_at Time.now
    feed_visibility 'Friends'
    sender_id 111111111
    event_type 'facebook_friend_signed_up'
    receiver_ids {FactoryGirl.create_list(:user, 2).collect &:id}
  end
  
  factory :beta_user do
    email
    newsletter false
    confirmed_at {Time.now - 3.days}
    factory :beta_user_not_confirmed do
      confirmed_at nil
      confirmation_token 'fooooooooo'
    end
  end

  factory :friendship do
    association :friend, factory: :user
    user
  end

  factory :admin_user do
    username
    password "secret"
    password_confirmation "secret"
    email
  end

  factory :tag do
    value Devise.friendly_token
    context Tag::GAME_CATEGORY_TYPE
  end

  factory :quest do
   description "Make it beautifull"
  end

  factory :like do
    association :user_task, factory: :user_task_verified
    user
  end

  factory :invitation do
    email
    invited_by {FactoryGirl.create(:user)}

    factory :game_invitation do
      invited_to {FactoryGirl.create(:game)}
    end
  end
end
