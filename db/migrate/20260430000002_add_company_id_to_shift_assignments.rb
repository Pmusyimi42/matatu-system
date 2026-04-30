class AddCompanyIdToShiftAssignments < ActiveRecord::Migration[8.1]
  def change
    add_column :shift_assignments, :company_id, :bigint
  end
end
