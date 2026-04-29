class ExpenseRecord < ApplicationRecord
  belongs_to :trip
  validates :description, presence: true
  validates :amount, presence: true
end
