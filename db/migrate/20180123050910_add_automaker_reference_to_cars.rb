class AddAutomakerReferenceToCars < ActiveRecord::Migration[5.1]
  def change
    # The foreign key and to_table specification is required when the actual table
    # name is something different than the accessor name you wish to use
    # this will cause the column:
    #
    # automaker_id
    #
    # which is a foreign key to my bt_automakers table, but that foreign key is
    # named automaker_id instead of bt_automaker_id
    #
    # This is all necessary because my belongs to association is with automaker,
    # so if I want that to work out of the box, I need to have my foreign key name
    # match that association name.
    #
    # A possible workaround instead of adding this, is to keep the foreign key bt_automaker_id
    # and change the belongs to to:
    #
    # belongs_to :automaker, foreign_key: 'bt_automaker_id'
    #
    add_reference :bt_cars, :automaker, foreign_key: {to_table: :bt_automakers}
  end
end
