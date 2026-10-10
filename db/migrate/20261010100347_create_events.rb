class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.string :category
      t.string :venue
      t.datetime :starts_at
      t.integer :duration
      t.string :mode
      t.string :image_url
      t.decimal :price

      t.timestamps
    end
  end
end
