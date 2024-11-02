# require all worker classes
Dir[Rails.root + 'lib/workers/*.rb'].each {|file| require file }

Notifications.subscribe 'set_game_completion_badges', GameCompletionWorker
Notifications.subscribe 'set_invitation_accepted_badges', InvitationAcceptedWorker
