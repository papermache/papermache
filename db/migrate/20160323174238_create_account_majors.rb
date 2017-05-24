class CreateAccountMajors < ActiveRecord::Migration
  def change
    create_table :account_majors do |t|
      t.references :account, index: true, foreign_key: true
      t.references :major, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
