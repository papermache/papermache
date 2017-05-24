class AccountMajor < ActiveRecord::Base
  belongs_to :major 
  belongs_to :account
end
