class CreateExpenseRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :expense_records do |t|
      t.references :trip, null: false, foreign_key: true
      t.string :description
      t.decimal :amount

      t.timestamps
    end
  end
end
