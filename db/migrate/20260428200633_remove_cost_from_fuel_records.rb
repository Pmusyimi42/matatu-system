class RemoveCostFromFuelRecords < ActiveRecord::Migration[8.1]
  def change
    remove_column :fuel_records, :cost, :decimal
  end
end
