class CreateHasManyUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :hm_users do |t|
      t.string :first_name
      t.string :last_name
      t.date :birthday

      t.timestamps
    end
  end
end
