class AddGraduationDateToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :graduation_date, :date
  end
end
