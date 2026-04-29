class ExpenseRecord < ApplicationRecord
  belongs_to :trip
  validates :description, presence: true
  validates :amount, presence: true
  validate :trip_must_be_active

  def trip_must_be_active
    return if trip&.active?

    errors.add(:base, "Cannot add expense to a completed trip")
  end
end
