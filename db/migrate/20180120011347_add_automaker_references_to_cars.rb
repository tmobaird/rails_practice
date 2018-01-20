class AddAutomakerReferencesToCars < ActiveRecord::Migration[5.1]
  def change
    add_reference :cars, :automaker
  end
end
