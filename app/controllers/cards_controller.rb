require "net/http"
require "uri"

class CardsController < ApplicationController
  # Garante que apenas Mestre logados acessem as cartas
  before_action :authenticate_user!
  before_action :require_master!

  def index
    if params[:query].present?
      @cards = current_user.cards.where("LOWER(name) LIKE ?", "%#{params[:query].downcase}%")
    else
      @cards = current_user.cards
    end

    @card = Card.new(category: :monster)
  end

  def new
    @card = current_user.cards.build(category: :monster, collection_id: params[:collection_id])
  end

  def create
    @card = current_user.cards.build(card_params)
    # Garante que a coleção pertence ao usuário atual
    if @card.collection_id.present?
      @card.collection = current_user.collections.find_by(id: @card.collection_id)
    end

    if @card.save
      if @card.collection_id.present?
        redirect_to collection_path(@card.collection_id), notice: "Carta criada com sucesso!"
      else
        redirect_to cards_path, notice: "Carta criada com sucesso!"
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # Busca a carta específica do Mestre logado
    @card = current_user.cards.find(params[:id])
  end

  def update
    @card = current_user.cards.find(params[:id])

    if @card.update(card_params)
      # Redireciona de volta para a grade de cartas recarregando as informações
      redirect_to cards_path, notice: "A carta foi reforjada com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # Busca a carta específica do Mestre
    @card = current_user.cards.find(params[:id])

    # Deleta do banco de dados
    @card.destroy

    # Redireciona com o status :see_other
    redirect_to cards_path, notice: "A carta foi apagada da existência.", status: :see_other
  end

  def generate_image
    raw_prompt = params[:description].to_s.strip

    if raw_prompt.blank?
      render json: { error: "A descrição para gerar a imagem é obrigatória." }, status: :bad_request
      return
    end

    begin
      card_context = params[:category].to_s == "monster" ? :card_monster : :card_item
      sanitized_prompt = PromptSanitizerService.new(raw_prompt, context: card_context).call
      puts "[Leonardo Prompt] #{sanitized_prompt}"
      result = LeonardoImageGenerationService.new.call(prompt: sanitized_prompt)

      if result[:success]
        render json: { image_url: result[:image_url] }
      else
        render json: { error: result[:error] }, status: result[:status]
      end

    rescue StandardError => e
      render json: { error: "Erro inesperado: #{e.message}" }, status: :internal_server_error
    end
  end

  private

  # Strong parameters: permite apenas os dados seguros que foram definidos no banco
  def card_params
    params.require(:card).permit(
      :name, :category, :health, :intelligence, :strength,
      :physical, :agility, :mental, :weight, :damage,
      :rarity, :active_bonus, :consumable, :description, :collection_id, :image_url
    )
  end
end
