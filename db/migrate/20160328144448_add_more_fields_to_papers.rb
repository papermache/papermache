class AddMoreFieldsToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :date_of_creating, :date
    add_column :papers, :professor, :string
    add_column :papers, :grade, :string
  end
end
