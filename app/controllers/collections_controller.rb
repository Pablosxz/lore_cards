class CollectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_collection, only: %i[ show edit update destroy add_card remove_card ]
  before_action :require_master!

  # GET /collections or /collections.json
  def index
    if params[:query].present?
      @collections = current_user.collections.where("LOWER(name) LIKE ?", "%#{params[:query].downcase}%")
    else
      @collections = current_user.collections
    end
  end

  # GET /collections/1
  def show
    @cards_in_collection = @collection.cards.includes(:user)
    @available_cards = current_user.cards.where.not(id: @cards_in_collection.select(:id))
  end

  # GET /collections/new
  def new
    @collection = current_user.collections.build
  end

  # GET /collections/1/edit
  def edit
  end

  # POST /collections or /collections.json
  def create
    @collection = current_user.collections.build(collection_params)

    respond_to do |format|
      if @collection.save
        format.html { redirect_to collection_path(@collection), notice: t(".created") }
        format.json { render :show, status: :created, location: @collection }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /collections/1 or /collections/1.json
  def update
    respond_to do |format|
      if @collection.update(collection_params)
        format.html { redirect_to collection_path(@collection), notice: t(".updated"), status: :see_other }
        format.json { render :show, status: :ok, location: @collection }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collections/1 or /collections/1.json
  def destroy
    @collection.destroy!

    respond_to do |format|
      format.html { redirect_to collections_path, notice: t(".destroyed"), status: :see_other }
      format.json { head :no_content }
    end
  end

  def add_card
    card = current_user.cards.find(params[:card_id])
    card.update!(collection: @collection)
    redirect_to collection_path(@collection), notice: "Carta adicionada à coleção."
  end

  def remove_card
    card = current_user.cards.find(params[:card_id])
    card.update!(collection: nil)
    redirect_to collection_path(@collection), notice: "Carta removida da coleção."
  end

  def generate_image
    raw_prompt = params[:description].to_s.strip

    if raw_prompt.blank?
      render json: { error: "A descrição para gerar a imagem é obrigatória." }, status: :bad_request
      return
    end

    begin
      sanitized_prompt = PromptSanitizerService.new(raw_prompt, context: :collection).call
      puts "[Leonardo Prompt Collection] #{sanitized_prompt}"

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
    # Use callbacks to share common setup or constraints between actions.
    def set_collection
      @collection = current_user.collections.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def collection_params
      params.require(:collection).permit(:name, :artistic_style, :image_url)
    end
end
