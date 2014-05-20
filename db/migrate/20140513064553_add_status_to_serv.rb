class AddStatusToServ < ActiveRecord::Migration
  def change
    add_column :servs, :status, :integer
  end
end
