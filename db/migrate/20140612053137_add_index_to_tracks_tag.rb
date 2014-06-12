class AddIndexToTracksTag < ActiveRecord::Migration
  def change
    add_index :tracks, [:tag, :user_id], unique: true
  end
end
