class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string   :token
      t.string   :email
      t.datetime :sent_at
      t.datetime :accepted_at
      t.integer  :invitee_id
      t.integer  :invited_by_id
      t.integer  :invited_to, polymorphic: true

      t.integer    :beta_invitations_budget
      t.references :download_link

      t.timestamps
    end
    add_index :invitations, :token, unique: true
    add_index :invitations, :invitee_id
    add_index :invitations, :invited_by_id
    add_index :invitations, [:email, :invited_by_id], unique: true
    add_index :invitations, [:invitee_id, :invited_by_id], unique: true
  end
end
