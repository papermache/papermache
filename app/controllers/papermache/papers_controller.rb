require 'rubygems'
require 'pdf/reader'

class Papermache::PapersController < ApplicationController
  before_action :find_paper, only: [:show, :edit, :update, :destroy, :pdfbrowse]
  helper_method :sort_column, :sort_direction
  
  def index
    # if params[:tag]
    #   @papers = Paper.tagged_with(params[:tag]).paginate(per_page: 10, page: params[:page])
    # else
    #   # Searc
    #   @papers = Paper.search(params[:query]).reorder(sort_column + ' ' + sort_direction).paginate(per_page: 10, page: params[:page])
    # end

    # Search
    @papers = ::Papermache::Paper.search(params[:query]).reorder(sort_column + ' ' + sort_direction).paginate(per_page: 10, page: params[:page])
  end

  def search
    @papers = ::Papermache::Paper.search(params[:query]).reorder(sort_column + ' ' + sort_direction).paginate(per_page: 10, page: params[:page])
  end

  def show
    @account = @paper.account
    @friends = @account.all_following + @account.followers
  end

  def create
    @paper = ::Papermache::Paper.new(paper_params)
    # Libreconv.convert(@paper.file.identifier, '/Users/daria/pdf_documents')

    if @paper.save
      redirect_to :back, notice: 'Paper successfully created.'
    else 
      redirect_to :back, notice: 'Something went wrong.'
    end 
  end

  # pdf view
  def pdfbrowse
    puts "asdhflkjahsdlkfhoqhweoirhqpowihfoihad*****************************************************************s;lhfoihqwoeihfopiwhsepohewopifhoihewoifhc"
  end

  # Voting

  def upvote
    @paper.upvote_by current_student
  end

  def downvote
    @paper.downvote_from current_student
  end

  def pdf_read

    filename = File.expand_path(File.dirname(__FILE__)) + "/../spec/data/cairo-unicode.pdf"

    PDF::Reader.open(filename) do |reader|
      reader.pages.each do |page|
        puts page.text
      end
    end
  end 

  private 

  # Defualt sort

  def sort_column
    params[:sort] || 'title'
  end

  def sort_direction
    params[:direction] || 'asc'
  end

  def find_paper
    @paper = ::Papermache::Paper.find(params[:id])
  end
  def paper_params
    params.require(:papermache_paper).permit(:title, :file, :tag_list, :about, :themes, :date_of_creating, :professor, :grade, :account_id)
  end

end

