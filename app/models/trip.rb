class Trip < ApplicationRecord
  has_one_attached :cash_proof_photo
  before_update :prevent_changes_if_completed


  belongs_to :vehicle
  belongs_to :route

  has_many :fuel_records
  has_many :expense_records
  has_many :delivery_records

  validates :vehicle_id, :route_id, :start_time, :status, presence: true

  validates :cash_collected, presence: true, if: :completed?
  validates :cash_proof_photo, presence: true, if: :completed?

  def active?
    status == "active"
  end

  def completed?
    status == "completed"
  end
  def complete_trip!(cash_collected:, cash_proof_photo:)
  transaction do
    # 1. attach photo FIRST
    self.cash_proof_photo.attach(cash_proof_photo)

    # 2. then update status
    update!(
      cash_collected: cash_collected,
      end_time: Time.current,
      status: "completed"
    )
  end
end
  def prevent_changes_if_completed
    if status_was == "completed"
      errors.add(:base, "Completed trip cannot be modified")
      throw(:abort)
    end
  end
end
