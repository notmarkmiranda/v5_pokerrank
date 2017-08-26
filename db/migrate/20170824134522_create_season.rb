class CreateSeason < ActiveRecord::Migration[5.1]
  def change
    create_table :seasons do |t|
      t.references :league, foreign_key: true
      t.boolean :active, default: true

      t.timestamps null: false
    end
  end
end
