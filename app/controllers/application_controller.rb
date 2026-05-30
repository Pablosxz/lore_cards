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
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: [ :username, :email, :role ]
    )
  end

  # Sobrescreve o destino padrão do Devise após o logout
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def after_sign_in_path_for(resource)
    if resource.player?
      authenticated_player_root_path
    else
      authenticated_master_root_path
    end
  end

  def require_master!
    redirect_to player_campaigns_path,
                alert: "Você não possui permissão para acessar esta área." unless current_user.master?
  end
end
