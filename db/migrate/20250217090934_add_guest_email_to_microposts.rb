class AddGuestEmailToMicroposts < ActiveRecord::Migration[7.0]
  def change
    add_column :microposts, :guest_email, :string
  end
end
