class CampaignParticipant < ApplicationRecord
  belongs_to :campaign
  belongs_to :user

  validate :user_must_be_player

  private

  def user_must_be_player
    errors.add(:user, "deve ser um jogador") unless user&.player?
  end
end
