class CardsController < ApplicationController
  # Garante que apenas Mestre logados acessem as cartas
  before_action :authenticate_user!

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

  private

  # Strong parameters: permite apenas os dados seguros que foram definidos no banco
  def card_params
    params.require(:card).permit(
      :name, :category, :health, :intelligence, :strength,
      :physical, :agility, :mental, :weight, :damage,
      :rarity, :active_bonus, :consumable, :description, :collection_id
    )
  end
end
