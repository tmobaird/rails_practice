class CreateBelongsToAutomakers < ActiveRecord::Migration[5.1]
  def change
    create_table :bt_automakers do |t|
      t.string :name
      t.integer :year_founded

      t.timestamps
    end
  end
end
