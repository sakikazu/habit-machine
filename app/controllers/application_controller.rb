class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  layout :select_layout
  before_filter :configure_permitted_parameters, if: :devise_controller?

  def select_layout
    if devise_controller?
      "devise"
    else
      "application"
    end
  end

  # deviseをStrongParameter対応させる
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) << [:familyname, :givenname]
  end
end
