class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.string :tag
      t.integer :user_id

      t.timestamps
    end
    add_index :tracks, [:user_id, :created_at]
  end
end
