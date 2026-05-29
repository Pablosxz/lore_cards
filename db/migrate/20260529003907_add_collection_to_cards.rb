class AddCollectionToCards < ActiveRecord::Migration[7.2]
  def change
    add_reference :cards, :collection, null: true, foreign_key: true
  end
end
