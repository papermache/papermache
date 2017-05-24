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
  end

end
