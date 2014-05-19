class AddOwnUserIdToTweets < ActiveRecord::Migration
  def change
    add_column :users, :tweets_count, :integer, default: 0
    add_column :tweets, :own_user_id, :integer
    add_index :tweets, :own_user_id
  end
end
