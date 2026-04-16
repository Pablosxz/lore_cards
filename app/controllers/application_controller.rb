class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  prepend_view_path Rails.root.join("app/views/components")

  layout :layout_by_resource

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def layout_by_resource
    devise_controller? ? "devise" : "application"
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
  end
end
