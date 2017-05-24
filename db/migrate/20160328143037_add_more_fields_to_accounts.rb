class AddMoreFieldsToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :gpa, :string
    add_column :accounts, :school, :string
    add_column :accounts, :graduation_year, :string
  end
end
