class AddAboutAndThemesToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :about, :text
    add_column :papers, :themes, :string
  end
end
