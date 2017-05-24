class AccountsController < ApplicationController
  
  before_action :find_account, only: [:show, :edit, :update, :destroy]
  autocomplete :account, :school, :full => true
  autocomplete :major, :name, :full => true, extra_data: [:id]

  helper_method :sort_column, :sort_direction

  def index 
    # @accounts = Account.all.where("id != ?", current_student.account)
    # Search
    @accounts = Account.search(params[:query]).reorder(sort_column + ' ' + sort_direction).paginate(per_page: 5, page: params[:page])

  end

  def show
    @friends = @account.all_following + @account.followers
  end

  def new
    @account = current_student.build_account
  end

  def create
    @account = current_student.build_account(account_params)
    if @account.student.has_edu_email?
      @account.edu_email = @account.student.email
    end

    if @account.save
      redirect_to @account, notice: 'Account successfuly created.'
    else
      render :new
    end
  end

  def edit 
  end

  def update
    if @account.update(account_params)
      redirect_to @account, notice: 'Account successfuly updated.' 
    else
      render :edit
    end
  end

  # Voting

  def upvote
    @account = Account.find(params[:id])
    @account.upvote_by current_student
  end

  def downvote
    @account = Account.find(params[:id])
    @account.downvote_from current_student
  end

  # Social Following

  def follow
    @account = Account.find(params[:id])
    current_student.account.follow(@account)
  end

  def unfollow
    @account = Account.find(params[:id])
    current_student.account.stop_following(@account)
  end

  private

  # Defualt sort

  def sort_column
    params[:sort] || 'first_name'
  end

  def sort_direction
    params[:direction] || 'asc'
  end

  def find_account
    @account = Account.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:first_name, :last_name, :edu_email, 
      :graduation_date, :graduation_year, :school, :gpa, :about_me, 
      :facebook_link, :twitter_link, :avatar,
      research_interests_attributes: [:id, :title, :_destroy], papers_attributes: [:id, :title, :file, :tag_list, :about, :themes, :date_of_creating, :professor, :grade, :_destroy], 
      major_ids: [], minor_ids: [])
  end

end
