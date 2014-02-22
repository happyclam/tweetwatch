class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.string :tag
      t.integer :user_id

      t.timestamps
    end
  end
end
