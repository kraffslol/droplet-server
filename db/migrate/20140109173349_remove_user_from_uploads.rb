class RemoveUserFromUploads < ActiveRecord::Migration
  def change
    remove_column :uploads, :user, :integer
  end
end
