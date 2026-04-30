class AddCompanyIdToExpenseRecords < ActiveRecord::Migration[8.1]
  def change
    add_column :expense_records, :company_id, :bigint
  end
end
