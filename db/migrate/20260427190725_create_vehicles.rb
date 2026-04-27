class CreateVehicles < ActiveRecord::Migration[8.1]
  def change
    create_table :vehicles do |t|
      t.string :plate_number
      t.integer :capacity
      t.string :status
      t.references :driver, null: false, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
