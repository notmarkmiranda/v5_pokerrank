class CreateLeagues < ActiveRecord::Migration[5.1]
  def change
    create_table :leagues do |t|
      t.string :name
      t.references :user, foreign_key: true
      t.string :slug

      t.timestamps null: false
    end
  end
end
