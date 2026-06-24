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
    prompt = params[:description].to_s.strip
    api_key = ENV["LEONARDO_API_KEY"]

    if api_key.blank?
      render json: { error: "Chave da API do Leonardo.ai não configurada." }, status: :internal_server_error
      return
    end

    if prompt.blank?
      render json: { error: "A descrição para gerar a imagem é obrigatória." }, status: :bad_request
      return
    end

    begin
      # 1. Solicita a geração da imagem
      uri = URI("https://cloud.leonardo.ai/api/rest/v1/generations")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      request["Authorization"] = "Bearer #{api_key}"
      request["Content-Type"] = "application/json"
      request["Accept"] = "application/json"
      request.body = {
        prompt: "RPG Card illustration of: #{prompt}. Fantasy art style, high quality, highly detailed.",
        modelId: "b2614463-296c-462a-9586-aafdb8f00e36",
        width: 512,
        height: 512,
        num_images: 1
      }.to_json

      response = http.request(request)
      result = JSON.parse(response.body)

      if response.code != "200"
        render json: { error: "Erro na API do Leonardo: #{result['error'] || response.message}" }, status: :bad_request
        return
      end

      generation_id = result.dig("sdGenerationJob", "generationId")

      # 2. Polling simples para aguardar URL da imagem gerada
      image_url = nil
      10.times do
        sleep 2
        status_uri = URI("https://cloud.leonardo.ai/api/rest/v1/generations/#{generation_id}")
        status_request = Net::HTTP::Get.new(status_uri)
        status_request["Authorization"] = "Bearer #{api_key}"
        status_request["Accept"] = "application/json"

        status_response = http.request(status_request)
        status_result = JSON.parse(status_response.body)

        images = status_result.dig("generations_by_pk", "generated_images")
        if images.present? && images.first["url"].present?
          image_url = images.first["url"]
          break
        end
      end

      if image_url
        render json: { image_url: image_url }
      else
        render json: { error: "A geração da imagem expirou ou falhou." }, status: :request_timeout
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
