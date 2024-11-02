class CreateBetaVolunteers < ActiveRecord::Migration
  def change
    create_table :beta_volunteers do |t|
      t.string :name
      t.string :email_addr

      t.timestamps
    end
  end
end
