class CreateServs < ActiveRecord::Migration
  def change
    create_table :servs do |t|
      t.string :track
      t.references :user, index: true

      t.timestamps
    end
  end
end
