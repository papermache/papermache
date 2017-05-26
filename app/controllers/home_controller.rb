class HomeController < ApplicationController
  skip_before_action :authenticate_student!, only: [:index]

  def index
    puts 'HomeController******************************'
    # if !current_user
    #   redirect_to main_path
    # end
  end
end
