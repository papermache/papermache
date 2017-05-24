class AddAboutMeToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :about_me, :text
  end
end
