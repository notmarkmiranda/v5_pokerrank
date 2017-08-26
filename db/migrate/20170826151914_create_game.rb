class CreateGame < ActiveRecord::Migration[5.1]
  def change
    create_table :games do |t|
      t.date :date
      t.integer :buy_in
      t.boolean :completed, default: false
      t.references :season, foreign_key: true
      t.integer :attendees
    end
  end
end
