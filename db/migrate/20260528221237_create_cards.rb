class CreateCards < ActiveRecord::Migration[7.2]
  def change
    create_table :cards do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.integer :category
      t.integer :health
      t.integer :intelligence
      t.integer :strength
      t.integer :physical
      t.integer :agility
      t.integer :mental
      t.decimal :weight
      t.integer :damage
      t.string :rarity
      t.string :active_bonus
      t.boolean :consumable

      t.timestamps
    end
  end
end
