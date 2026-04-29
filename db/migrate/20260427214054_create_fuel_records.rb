class CreateFuelRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :fuel_records do |t|
      t.references :trip, null: false, foreign_key: true
      t.decimal :amount
      t.decimal :cost

      t.timestamps
    end
  end
end
