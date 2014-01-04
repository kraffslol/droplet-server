class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :login
      t.string :hashed_password
      t.integer :plan
      t.integer :uploadsleft

      t.timestamps
    end
  end
end
