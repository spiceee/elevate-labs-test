class CreateApiTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :api_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :active
      t.text :token
      t.index :token, unique: true
      t.timestamps
    end
  end
end
