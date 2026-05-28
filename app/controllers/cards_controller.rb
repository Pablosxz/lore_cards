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
    @card = current_user.cards.build(category: :monster)
  end

  def create
    @card = current_user.cards.build(card_params)

    if @card.save
      redirect_to cards_path, notice: "Carta criada com sucesso!"
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
      :rarity, :active_bonus, :consumable, :description
    )
  end
end
