class AddDescriptionToCards < ActiveRecord::Migration[7.2]
  def change
    add_column :cards, :description, :text
  end
end
