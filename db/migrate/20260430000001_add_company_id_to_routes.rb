class AddCompanyIdToRoutes < ActiveRecord::Migration[8.1]
  def change
    add_column :routes, :company_id, :bigint
  end
end
