class CreateCampaignParticipants < ActiveRecord::Migration[7.2]
  def change
    create_table :campaign_participants do |t|
      t.references :campaign, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :campaign_participants,
              [ :campaign_id, :user_id ],
              unique: true
  end
end
