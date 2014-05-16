class AddCmdParamsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :c_key, :string
    add_column :users, :c_secret, :string
    add_column :users, :a_key, :string
    add_column :users, :a_secret, :string
  end
end
