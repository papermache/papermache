class AddUidAndProviderToStudents < ActiveRecord::Migration
  def change
    add_column :students, :uid, :string
    add_column :students, :provider, :string
  end
end
