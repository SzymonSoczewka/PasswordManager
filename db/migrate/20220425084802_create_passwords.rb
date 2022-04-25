class CreatePasswords < ActiveRecord::Migration[6.1]
  def change
    create_table :passwords do |t|
      t.string :crypted_password
      t.string :password_salt

      t.timestamps
    end
  end
end
