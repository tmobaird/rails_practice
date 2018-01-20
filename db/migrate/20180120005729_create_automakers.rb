class CreateAutomakers < ActiveRecord::Migration[5.1]
  def change
    create_table :automakers do |t|
      t.string :name
      t.integer :year_founded

      t.timestamps
    end
  end
end
