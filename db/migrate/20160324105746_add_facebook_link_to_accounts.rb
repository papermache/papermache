class AddFacebookLinkToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :facebook_link, :string
  end
end
