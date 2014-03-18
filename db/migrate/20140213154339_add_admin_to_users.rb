class AddAdminToUsers < ActiveRecord::Migration
  def change
    add_column :users, :admin, :tinyint, default: 0
  end
end
