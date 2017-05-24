class ApplicationController < ActionController::Base
  before_action :authenticate_student!
  
  protect_from_forgery with: :exception

  protected

  # Redirect to profile after login
  def after_sign_in_path_for(resource)
    if current_student.account
      account_path(current_student.account)
    else
      new_account_path
    end  
  end

end
