class AddTimesToShiftAssignments < ActiveRecord::Migration[7.1]
  def change
    add_column :shift_assignments, :start_time, :datetime
    add_column :shift_assignments, :end_time, :datetime
  end
end
