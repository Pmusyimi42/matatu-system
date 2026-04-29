class Trip < ApplicationRecord
  # =========================
  # ATTACHMENTS
  # =========================
  has_one_attached :cash_proof_photo

  # =========================
  # ASSOCIATIONS
  # =========================
  belongs_to :vehicle
  belongs_to :route

  has_many :fuel_records, dependent: :destroy
  has_many :expense_records, dependent: :destroy

  # =========================
  # VALIDATIONS
  # =========================
  validates :vehicle_id, :route_id, :start_time, :status, presence: true
  validates :cash_collected, presence: true, if: :completed?
  validates :cash_proof_photo, presence: true, if: :completed?

  # =========================
  # CALLBACKS
  # =========================
  before_update :prevent_changes_if_completed

  # =========================
  # STATUS HELPERS
  # =========================
  def active?
    status == "active"
  end

  def completed?
    status == "completed"
  end

  def locked?
    completed?
  end

  # =========================
  # BUSINESS LOGIC
  # =========================
  def complete_trip!(cash_collected:, cash_proof_photo:)
    transaction do
      # Attach photo properly
      self.cash_proof_photo.attach(
        io: cash_proof_photo[:io],
        filename: cash_proof_photo[:filename],
        content_type: cash_proof_photo[:content_type]
      )

      # Update trip
      update!(
        cash_collected: cash_collected,
        end_time: Time.current,
        status: "completed"
      )
    end
  end

  # =========================
  # LOCKING LOGIC
  # =========================
  def prevent_changes_if_completed
    # Allow the moment we mark it completed
    return if will_save_change_to_status? && status == "completed"

    return unless locked?

    allowed = %w[updated_at]

    if (changes.keys - allowed).any?
      errors.add(:base, "Trip is locked and cannot be modified")
      throw(:abort)
    end
  end
end
