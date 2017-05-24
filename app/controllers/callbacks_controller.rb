class CallbacksController < Devise::OmniauthCallbacksController
  def facebook
    student = Student.from_omniauth(request.env["omniauth.auth"])
    if student.persisted?
      sign_in_and_redirect student
    else
      redirect_to new_student_registration_path
    end
  end
end