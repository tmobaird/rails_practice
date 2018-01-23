class AddAutomakerReferenceToCars < ActiveRecord::Migration[5.1]
  def change
    add_reference :bt_cars, :automaker
  end
end
