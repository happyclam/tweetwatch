class AddStatusToServ < ActiveRecord::Migration
  def change
    add_column :servs, :status, :integer, default: 0
  end
end
