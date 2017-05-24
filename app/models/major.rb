class Major < ActiveRecord::Base
  validates :name, presence: true
  has_many :account_majors
  has_many :accounts, through: :account_majors
end
