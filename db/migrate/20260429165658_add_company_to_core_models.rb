class AddCompanyToCoreModels < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :company, foreign_key: true
    add_reference :vehicles, :company, foreign_key: true
    add_reference :trips, :company, foreign_key: true
  end
end
