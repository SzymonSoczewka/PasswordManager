class CreatePasswords < ActiveRecord::Migration[6.1]
  def change
    create_table :passwords do |t|
      t.string :url, null: false
      t.string :username, null: false
      t.string :password, null: false

      t.timestamps
    end
  end
end
