class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include ApplicationHelper

  layout :select_layout
  before_action :configure_permitted_parameters, if: :devise_controller?

  def select_layout
    if devise_controller?
      "devise"
    else
      "application"
    end
  end

  # deviseをStrongParameter対応させる
  def configure_permitted_parameters
    # devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:familyname, :givenname, :nickname])
  end
end
