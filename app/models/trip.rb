class Trip < ApplicationRecord
  include TenantScoped

  has_one_attached :cash_proof_photo

  belongs_to :vehicle
  belongs_to :route
  has_many :fuel_records, dependent: :destroy
  has_many :expense_records, dependent: :destroy

  validates :vehicle_id, :route_id, :start_time, :status, presence: true
  validates :cash_collected, presence: true, if: :completed?
  validates :cash_proof_photo, presence: true, if: :completed?

  before_update :prevent_changes_if_completed

  def active?
    status == "active"
  end

  def completed?
    status == "completed"
  end

  def locked?
    completed?
  end

  def complete_trip!(cash_collected:, cash_proof_photo:)
  transaction do
    self.cash_proof_photo.attach(cash_proof_photo)

    update!(
      cash_collected: cash_collected,
      end_time: Time.current,
      status: "completed"
    )
  end
end

  private

  def prevent_changes_if_completed
    return if will_save_change_to_status? && status_was != "completed" && status == "completed"
    return unless locked?

    allowed = %w[updated_at]

    if (changes.keys - allowed).any?
      errors.add(:base, "Trip is locked and cannot be modified")
      throw(:abort)
    end
  end
end

