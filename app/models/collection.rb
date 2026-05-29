class Collection < ApplicationRecord
  belongs_to :user
  has_many :cards, dependent: :nullify
end
