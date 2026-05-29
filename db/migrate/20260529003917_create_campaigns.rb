class CreateCampaigns < ActiveRecord::Migration[7.2]
  def change
    create_table :campaigns do |t|
      t.string :name
      t.text :base_story
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
