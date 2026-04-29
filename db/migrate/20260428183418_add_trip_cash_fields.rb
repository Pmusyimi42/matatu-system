class AddTripCashFields < ActiveRecord::Migration[8.1]
  def change
    add_column :trips, :cash_collected, :decimal
  end
end
