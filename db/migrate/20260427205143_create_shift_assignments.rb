class CreateShiftAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :shift_assignments do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.references :driver, null: false, foreign_key: {to_table: :users}
      t.string :status

      t.timestamps
    end
  end
end
