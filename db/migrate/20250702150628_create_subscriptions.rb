class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :active
      t.datetime :last_checked_at

      t.timestamps
    end
  end
end
