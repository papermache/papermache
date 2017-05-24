class AddCachedVotesToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :cached_votes_total, :integer, default: 0
    add_column :accounts, :cached_votes_score, :integer, default: 0
    add_column :accounts, :cached_votes_up, :integer, default: 0
    add_column :accounts, :cached_votes_down, :integer, default: 0
    add_index  :accounts, :cached_votes_total
    add_index  :accounts, :cached_votes_score
    add_index  :accounts, :cached_votes_up
    add_index  :accounts, :cached_votes_down

    # Force caching of existing votes
    Account.find_each(&:update_cached_votes)
  end

  def self.down 
    remove_column :accounts, :cached_votes_total
    remove_column :accounts, :cached_votes_score
    remove_column :accounts, :cached_votes_up 
    remove_column :accounts, :cached_votes_down
  end

end
