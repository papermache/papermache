class AddCachedVotesToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :cached_votes_total, :integer, default: 0
    add_column :papers, :cached_votes_score, :integer, default: 0
    add_column :papers, :cached_votes_up, :integer, default: 0
    add_column :papers, :cached_votes_down, :integer, default: 0
    add_index  :papers, :cached_votes_total
    add_index  :papers, :cached_votes_score
    add_index  :papers, :cached_votes_up
    add_index  :papers, :cached_votes_down

    # Force caching of existing votes
    Papermache::Paper.find_each(&:update_cached_votes)
  end

  def self.down 
    remove_column :papers, :cached_votes_total
    remove_column :papers, :cached_votes_score
    remove_column :papers, :cached_votes_up 
    remove_column :papers, :cached_votes_down
  end
end
