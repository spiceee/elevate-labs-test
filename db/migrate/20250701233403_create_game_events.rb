class CreateGameEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :game_events do |t|
      t.references :user, null: false, foreign_key: true
      t.string :game_name
      t.integer :kind, default: 0
      t.index :game_name
      t.datetime :occurred_at
      t.timestamps
    end
  end
end
