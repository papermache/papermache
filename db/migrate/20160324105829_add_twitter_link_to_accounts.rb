class AddTwitterLinkToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :twitter_link, :string
  end
end
