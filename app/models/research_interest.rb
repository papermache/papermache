class ResearchInterest < ActiveRecord::Base
  validates :title, presence: true
  belongs_to :account
end
