class AddEduEmailToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :edu_email, :string
  end
end
