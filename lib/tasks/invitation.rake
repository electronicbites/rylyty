namespace :invitation do

  def invite opts
    opts[:invited_by] = if (invited_by_id = opts.delete(:invited_by_id)).present?
      User.find(invited_by_id)
    end

    begin
      i = Invitation.create! opts
      puts "Invited #{i.email}#{' by ' + i.invited_by.email if i.invited_by} with token #{i.token}"
    rescue ActiveRecord::RecordInvalid => e
      puts "Could not create invitation for #{opts[:email]}: #{e.message}"
    end
  end

  desc "Reads a list of emails from STDIN and create an Invitation for each of them"
  task :batch, [:invited_by_id, :beta_invitations_budget] => :environment  do |t, args|
    args.with_defaults(invited_by_id: nil, beta_invitations_budget: 10)
    STDIN.read.split.each do |email|
      invite args.to_hash.merge({email: email})
    end
  end

  desc "Creates a single Invitation"
  task :single, [:email, :invited_by_id, :beta_invitations_budget] => :environment do |t, args|
    args.with_defaults(invited_by_id: nil, beta_invitations_budget: 10)
    raise "Cannot invite without an email. run: rake invitation:single[foo@example.com]" unless args[:email].present?
    invite(args.to_hash)
  end

  task :drop_all => :environment do
    r = Invitation.delete_all
    puts "Deleted all #{r} invitations"
  end

end