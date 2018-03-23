class CreateRecipes < ActiveRecord::Migration[5.1]
  def change
    create_table :recipes do |t|
      t.string :title
      t.string :url
      t.integer :numFavorites
      t.string :imageurl

      t.timestamps
    end
  end
end
