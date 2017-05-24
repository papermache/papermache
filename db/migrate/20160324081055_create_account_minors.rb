class CreateAccountMinors < ActiveRecord::Migration
  def change
    create_table :account_minors do |t|
      t.references :account, index: true, foreign_key: true
      t.references :minor, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
