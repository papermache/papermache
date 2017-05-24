class AccountMinor < ActiveRecord::Base
  belongs_to :account
  belongs_to :minor
end
