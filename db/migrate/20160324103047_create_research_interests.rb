class CreateResearchInterests < ActiveRecord::Migration
  def change
    create_table :research_interests do |t|
      t.string :title
      t.references :account, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
