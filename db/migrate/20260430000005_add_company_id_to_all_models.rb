class AddCompanyIdToAllModels < ActiveRecord::Migration[7.1]
  def change
    # Add company_id to tables that don't have it
    add_reference :routes, :company, foreign_key: true unless column_exists?(:routes, :company_id)
    add_reference :shift_assignments, :company, foreign_key: true unless column_exists?(:shift_assignments, :company_id)
    add_reference :expense_records, :company, foreign_key: true unless column_exists?(:expense_records, :company_id)
    add_reference :fuel_records, :company, foreign_key: true unless column_exists?(:fuel_records, :company_id)

    # Add NOT NULL constraints (will fail if NULLs exist, but db is fresh)
    change_column_null :users, :company_id, false
    change_column_null :vehicles, :company_id, false
    change_column_null :trips, :company_id, false
    change_column_null :routes, :company_id, false
    change_column_null :shift_assignments, :company_id, false
    change_column_null :expense_records, :company_id, false
    change_column_null :fuel_records, :company_id, false
  end
end

