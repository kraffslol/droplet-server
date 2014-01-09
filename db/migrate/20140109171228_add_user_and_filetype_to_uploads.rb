class AddUserAndFiletypeToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :user, :integer
    add_column :uploads, :filetype, :string
  end
end
