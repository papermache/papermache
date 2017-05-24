class Minor < ActiveRecord::Base
  validates :name, presence: true
  has_many :account_minors
  has_many :accounts, through: :account_minors
end
