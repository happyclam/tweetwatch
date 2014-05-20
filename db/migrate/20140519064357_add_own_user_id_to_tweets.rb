class AddOwnUserIdToTweets < ActiveRecord::Migration
  def change
    add_column :users, :tweets_count, :integer, default: 0

  end
end
