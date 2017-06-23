class AddCachedVotesExtraToPapers < ActiveRecord::Migration
  def self.up
    add_column :papers, :cached_weighted_score, :integer, :default => 0
    add_column :papers, :cached_weighted_total, :integer, :default => 0
    add_column :papers, :cached_weighted_average, :float, :default => 0.0
    add_index  :papers, :cached_weighted_score
    add_index  :papers, :cached_weighted_total
    add_index  :papers, :cached_weighted_average

    # Uncomment this line to force caching of existing votes
    Papermache::Paper.find_each(&:update_cached_votes)
  end

  def self.down
    remove_column :papers, :cached_weighted_score
    remove_column :papers, :cached_weighted_total
    remove_column :papers, :cached_weighted_average
  end
end
