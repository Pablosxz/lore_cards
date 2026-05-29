class Collection < ApplicationRecord
  belongs_to :user
  has_many :cards, dependent: :nullify
  has_and_belongs_to_many :campaigns
end
