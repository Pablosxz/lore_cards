class AddImageUrlToCards < ActiveRecord::Migration[7.2]
  def change
    add_column :cards, :image_url, :string
  end
end
