class ApplicationController < ActionController::Base
  protect_from_forgery
  layout :select_layout

  def select_layout
    if devise_controller?
      "devise"
    else
      "application"
    end
  end

end
