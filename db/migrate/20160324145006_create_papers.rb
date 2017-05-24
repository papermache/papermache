class CreatePapers < ActiveRecord::Migration
  def change
    create_table :papers do |t|
      t.string :title
      t.string :file
      t.references :account, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
