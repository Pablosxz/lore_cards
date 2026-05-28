class Card < ApplicationRecord
  belongs_to :user

  # Define os tipos de carta. No banco salva 0 ou 1, no código :monster ou :item
  enum category: { monster: 0, item: 1 }

  # Validações básicas
  validates :name, presence: true
  validates :category, presence: true
end
