class TestController < ApplicationController
  # skip_before_action :authenticate_student!
  def index
    @temp = Account.all
  end
  def sma_detail_view
    @paper = Papermache::Paper.find(params[:id])
    @accounts = @paper.votes_for
    @peers = @accounts.size
    @yea_votes = @paper.votes_for.up.sum(:vote_weight)
    @nay_votes = @paper.votes_for.down.sum(:vote_weight)
    @sum = @yea_votes - @nay_votes
    @result = @paper.sma_detail
  end
  def qr_detail_view
    @account = Account.find(params[:id])

    # All votes diff score analystic data
    @papers = @account.papers
    total = @papers.sum(:cached_weighted_total)
    score = @papers.sum(:cached_weighted_score)
    @yea_votes = (total + score) / 2
    @nay_votes = (total - score) / 2
    @yea_peers = @papers.sum(:cached_votes_up)
    @nay_peers = @papers.sum(:cached_votes_down)
    @yea_avg = 0
    @nay_avg = 0
    @yea_avg = @yea_votes / @yea_peers if @yea_peers > 0
    @nay_avg = @nay_votes / @nay_peers if @nay_peers > 0
    @diff = @yea_avg - @nay_avg

    # Gain/Losess analistic data
    @voted_papers = @account.voted_papers
    # @voted_papers = @account.student.get_voted Papermache::Paper
    # @upvoted_papers = @account.student.get_up_voted Papermache::Paper

    @upvote_cast = @account.student.votes.up.for_type(Papermache::Paper).sum(:vote_weight)
    @downvote_cast = @account.student.votes.down.for_type(Papermache::Paper).sum(:vote_weight)
    @yea_papers = @account.student.votes.up.for_type(Papermache::Paper).size
    @nay_papers = @account.student.votes.down.for_type(Papermache::Paper).size
    @yea_cast_avg = 0
    @nay_cast_avg = 0
    @yea_cast_avg = (@upvote_cast / @yea_papers).to_d.truncate(2).to_s if @yea_papers > 0
    @nay_cast_avg = (@downvote_cast / @nay_papers).to_d.truncate(2).to_s if @nay_papers > 0
    @gain_losses  = @account.gain_losses_all

    # QR
    @qr = @account.quantified_reputation
  end
end
