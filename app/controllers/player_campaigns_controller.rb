class PlayerCampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_player!

  def index
    @campaigns = current_user.joined_campaigns
                           .includes(collections: :cards)
  end

  private

  def ensure_player!
    redirect_to dashboard_index_path unless current_user.player?
  end
end
