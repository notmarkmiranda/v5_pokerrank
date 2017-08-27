class CreateParticipant < ActiveRecord::Migration[5.1]
  def change
    create_table :participants do |t|
      t.string :first_name
      t.string :last_name
      t.references :user, foreign_key: true
    end
  end
end
