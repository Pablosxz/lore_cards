class CreateJoinTableCampaignCollections < ActiveRecord::Migration[7.2]
  def change
    create_join_table :campaigns, :collections do |t|
      t.index [:campaign_id, :collection_id]
      t.index [:collection_id, :campaign_id]
    end
  end
end
