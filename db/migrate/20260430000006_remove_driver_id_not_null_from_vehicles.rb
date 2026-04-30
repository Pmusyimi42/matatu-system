class RemoveDriverIdNotNullFromVehicles < ActiveRecord::Migration[7.1]
  def change
    change_column_null :vehicles, :driver_id, true
  end
end
