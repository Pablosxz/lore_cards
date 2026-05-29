class CampaignsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_campaign,
                only: %i[
                  show
                  edit
                  update
                  destroy
                  add_collection
                  remove_collection
                  invite_player
                  remove_player
                ]

  def index
    if params[:query].present?
      @campaigns = current_user.campaigns.where("LOWER(name) LIKE ?", "%#{params[:query].downcase}%")
    else
      @campaigns = current_user.campaigns
    end
  end

  def show
    @campaign_collections = @campaign.collections
    @available_collections = current_user.collections.where.not(id: @campaign.collection_ids)
  end

  def add_collection
    collection = current_user.collections.find(params[:collection_id])

    @campaign.collections << collection unless @campaign.collections.include?(collection)

    redirect_to @campaign, notice: "Coleção vinculada com sucesso."
  end

  def remove_collection
    collection = current_user.collections.find(params[:collection_id])

    @campaign.collections.delete(collection)

    redirect_to @campaign, notice: "Coleção removida da campanha."
  end

  def invite_player
    user = User.find_by(email: params[:email])

    if user.nil?
      redirect_to @campaign, alert: "Usuário não encontrado."
      return
    end

    unless user.player?
      redirect_to @campaign, alert: "Esse usuário não é um jogador."
      return
    end

    if @campaign.players.include?(user)
      redirect_to @campaign, alert: "Jogador já participa da campanha."
      return
    end

    @campaign.players << user

    redirect_to @campaign,
                notice: "Jogador adicionado à campanha com sucesso."
  end

  def new
    @campaign = current_user.campaigns.build
  end

  def edit
  end

  def create
    @campaign = current_user.campaigns.build(campaign_params)

    respond_to do |format|
      if @campaign.save
        format.html { redirect_to campaigns_path, notice: t(".created") }
        format.json { render :show, status: :created, location: @campaign }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @campaign.update(campaign_params)
        format.html { redirect_to campaigns_path, notice: t(".updated"), status: :see_other }
        format.json { render :show, status: :ok, location: @campaign }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @campaign.destroy!

    respond_to do |format|
      format.html { redirect_to campaigns_path, notice: t(".destroyed"), status: :see_other }
      format.json { head :no_content }
    end
  end

  def remove_player
    player = User.find(params[:player_id])

    @campaign.players.delete(player)

    redirect_to @campaign,
                notice: "Jogador removido da campanha."
  end

  private

  def set_campaign
    @campaign = current_user.campaigns.find(params[:id])
  end

  def campaign_params
    params.require(:campaign).permit(:name, :base_story)
  end
end
