class AddUserIdToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :userid, :integer
  end
end
