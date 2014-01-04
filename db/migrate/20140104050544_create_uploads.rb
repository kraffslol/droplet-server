class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.string :slug
      t.string :filename
      t.integer :views

      t.timestamps
    end
  end
end
