class PapermacheController < ApplicationController
  skip_before_action :authenticate_student!, only: [:home, :sign_up]

  def home
  end

  def profile
  end

  def sign_up
  end

  def log_in
  end

  def search
    if params[:peer].present? && params[:peer] == 'true'
      @account_data = Account.search(params[:search])
    elsif params[:paper].present? && params[:paper] == 'true'
      @paper_data = ::Papermache::Paper.search(params[:search])
    else

    end
  end

end
