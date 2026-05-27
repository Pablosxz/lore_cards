class DashboardController < ApplicationController
  before_action :authenticate_index, only: [:index]

  def index
  end

  private

  def authenticate_index
    # Verifica se o usuário não está logado
    unless user_signed_in?
      store_location_for(:user, request.fullpath)
      redirect_to new_user_session_path
    end
  end
end
