class AddCompanyIdToFuelRecords < ActiveRecord::Migration[8.1]
  def change
    add_column :fuel_records, :company_id, :bigint
  end
end
