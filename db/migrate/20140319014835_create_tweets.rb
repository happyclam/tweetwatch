class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.integer :own_user_id, null: false, default: 0
      t.integer :user_id, null: false, default: 0
      t.string :user_name, null: false
      t.string :user_screen_name, null: false
      t.string :user_image
      t.text :user_description
      t.text :user_text
      t.string :post_hashtags
      t.integer :status_id
      t.integer :reply_status_id
      t.integer :reply_user_id
      t.string :reply_user_screen_name

      t.timestamps
    end
    add_index :tweets, [:own_user_id, :created_at]
  end
end
