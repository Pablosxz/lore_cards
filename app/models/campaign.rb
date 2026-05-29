class Campaign < ApplicationRecord
  belongs_to :user

  has_many :campaign_participants, dependent: :destroy
  has_many :players,
           through: :campaign_participants,
           source: :user

  has_and_belongs_to_many :collections
end
