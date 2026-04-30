class Trip < ApplicationRecord
  include TenantScoped

  has_one_attached :cash_proof_photo

  belongs_to :vehicle
  belongs_to :route
  belongs_to :driver, class_name: "User", optional: true
  has_many :fuel_records, dependent: :destroy
  has_many :expense_records, dependent: :destroy

  validates :vehicle_id, :route_id, :start_time, :status, presence: true
  validates :cash_collected, presence: true, if: :completed?
  validates :cash_proof_photo, presence: true, if: :completed?

  before_update :prevent_changes_if_completed

  scope :this_month, -> { where("start_time >= ?", Time.current.beginning_of_month) }
  scope :for_driver, ->(driver) { where(driver_id: driver.id) }
  scope :completed, -> { where(status: "completed") }
  scope :active, -> { where(status: "active") }

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
      update!(
        cash_collected: cash_collected,
        end_time: Time.current,
        status: "completed"
      )
      self.cash_proof_photo.attach(cash_proof_photo)
    end
  end

  def duration_minutes
    return nil unless end_time && start_time
    ((end_time - start_time) / 60).round
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
